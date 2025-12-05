import android.app.Service
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.IBinder
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import kotlinx.coroutines.*
import org.json.JSONArray
import java.net.URL

class StrategyService : Service() {
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val symbol = intent?.getStringExtra("symbol") ?: "BTCUSDT"
        val timeframe = intent?.getStringExtra("timeframe") ?: "1m"

        val persistent = NotificationCompat.Builder(this, "strategy_channel")
            .setContentTitle("Foreground Strategy")
            .setContentText("در حال بررسی $symbol @ $timeframe")
            .setSmallIcon(R.drawable.ic_notification)
            .build()
        startForeground(1, persistent)

        scope.launch { runLoop(symbol, timeframe) }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null
    override fun onDestroy() { scope.cancel() }

    private suspend fun runLoop(symbol: String, timeframe: String) {
        val intervalSec = mapTfToSeconds(timeframe)
        while (isActive) {
            try {
                val candles = fetchCandles(symbol, timeframe, 200)
                val closes = candles.map { it.close }

                val ema50 = ema(closes, 50)
                val macdRes = macd(closes)
                val rsi14 = rsi(closes, 14)
                val ichi = ichimoku(candles)

                val lastClose = price(candles, PriceField.CLOSE, 0)
                val prevClose = price(candles, PriceField.CLOSE, 1)
                val lastEma = ema50.lastOrNull()
                val prevEma = ema50.dropLast(1).lastOrNull()
                val lastRsi = rsi14.lastOrNull()
                val lastTenkan = ichi.tenkan.lastOrNull()
                val lastKijun  = ichi.kijun.lastOrNull()

                // نمونه شرط‌ها
                val B1 = compare(Op.GT, lastClose, lastEma)
                val B2 = between(lastRsi, 20.0, 80.0)
                val B3 = cross(Cross.UP, prevClose, prevEma, lastClose, lastEma)
                val B4 = compare(Op.GT, lastTenkan, lastKijun)

                val strategy = (B1 && B3) && B4 && B2

                if (strategy) {
                    val chartUrl = buildTradingViewUrl(symbol, timeframe)
                    showAlertNotification(this@StrategyService, symbol, timeframe, chartUrl)
                }
            } catch (e: Exception) { e.printStackTrace() }
            delay(intervalSec * 1000L)
        }
    }

    // ===== ابزارها و اندیکاتورها =====
    data class Candle(val time: Long, val open: Double, val high: Double, val low: Double, val close: Double, val volume: Double)
    enum class PriceField { OPEN, HIGH, LOW, CLOSE }
    enum class Op { GT, LT, EQ }
    enum class Cross { UP, DOWN }
    data class IchimokuResult(val tenkan: List<Double?>, val kijun: List<Double?>, val senkouA: List<Double?>, val senkouB: List<Double?>)
    data class MacdResult(val macd: List<Double?>, val signal: List<Double?>, val hist: List<Double?>)

    private fun fetchCandles(symbol: String, interval: String, limit: Int = 200): List<Candle> {
        val url = "https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval&limit=$limit"
        val json = URL(url).readText()
        val arr = JSONArray(json)
        val out = mutableListOf<Candle>()
        for (i in 0 until arr.length()) {
            val k = arr.getJSONArray(i)
            out.add(Candle(k.getLong(0), k.getDouble(1), k.getDouble(2), k.getDouble(3), k.getDouble(4), k.getDouble(5)))
        }
        return out
    }

    private fun price(candles: List<Candle>, field: PriceField, indexFromLast: Int = 0): Double? {
        val idx = candles.size - 1 - indexFromLast
        if (idx < 0) return null
        return when (field) {
            PriceField.OPEN -> candles[idx].open
            PriceField.HIGH -> candles[idx].high
            PriceField.LOW -> candles[idx].low
            PriceField.CLOSE -> candles[idx].close
        }
    }

    private fun ema(values: List<Double>, period: Int): List<Double?> {
        if (values.size < period) return List(values.size) { null }
        val out = MutableList(values.size) { null as Double? }
        val k = 2.0 / (period + 1)
        var e = values.take(period).average()
        out[period - 1] = e
        for (i in period until values.size) {
            e = values[i]  k + e  (1 - k)
            out[i] = e
        }
        return out
    }
// ادامه‌ی MACD
    private fun macd(values: List<Double>, fast: Int = 12, slow: Int = 26, signal: Int = 9): MacdResult {
        val ef = ema(values, fast)
        val es = ema(values, slow)
        val m = values.indices.map { i -> if (ef[i] == null || es[i] == null) null else ef[i]!! - es[i]!! }
        val s = ema(m.map { it ?: 0.0 }, signal)
        val h = m.indices.map { i -> if (m[i] == null || s[i] == null) null else m[i]!! - s[i]!! }
        return MacdResult(m, s, h)
    }

    // A: RSI
    private fun rsi(values: List<Double>, period: Int = 14): List<Double?> {
        val out = MutableList(values.size) { null as Double? }
        if (values.size <= period) return out
        for (i in period until values.size) {
            var gains = 0.0
            var losses = 0.0
            for (j in i - period + 1..i) {
                val diff = values[j] - values[j - 1]
                if (diff >= 0) gains += diff else losses -= diff
            }
            val avgGain = gains / period
            val avgLoss = losses / period
            val rs = if (avgLoss == 0.0) Double.POSITIVE_INFINITY else avgGain / avgLoss
            out[i] = 100 - (100 / (1 + rs))
        }
        return out
    }

    // A: Ichimoku
    private fun ichimoku(candles: List<Candle>, tenkanPeriod: Int = 9, kijunPeriod: Int = 26, senkouPeriod: Int = 52): IchimokuResult {
        val highs = candles.map { it.high }
        val lows = candles.map { it.low }

        fun mid(i: Int, period: Int): Double {
            val h = highs.subList(i - period + 1, i + 1).maxOrNull() ?: 0.0
            val l = lows.subList(i - period + 1, i + 1).minOrNull() ?: 0.0
            return (h + l) / 2.0
        }

        val size = candles.size
        val tenkan = MutableList(size) { null as Double? }
        val kijun = MutableList(size) { null as Double? }
        val senkouA = MutableList(size) { null as Double? }
        val senkouB = MutableList(size) { null as Double? }

        for (i in 0 until size) {
            if (i >= tenkanPeriod - 1) tenkan[i] = mid(i, tenkanPeriod)
            if (i >= kijunPeriod - 1) kijun[i] = mid(i, kijunPeriod)
            if (i >= kijunPeriod - 1 && tenkan[i] != null && kijun[i] != null) {
                senkouA[i] = (tenkan[i]!! + kijun[i]!!) / 2.0
            }
            if (i >= senkouPeriod - 1) senkouB[i] = mid(i, senkouPeriod)
        }
        return IchimokuResult(tenkan, kijun, senkouA, senkouB)
    }

    // B: مقایسه ساده
    private fun compare(op: Op, left: Double?, right: Double?): Boolean {
        if (left == null || right == null) return false
        return when (op) {
            Op.GT -> left > right
            Op.LT -> left < right
            Op.EQ -> left == right
        }
    }

    // B: عبور
    private fun cross(type: Cross, prevLeft: Double?, prevRight: Double?, lastLeft: Double?, lastRight: Double?): Boolean {
        if (prevLeft == null || prevRight == null || lastLeft == null || lastRight == null) return false
        return when (type) {
            Cross.UP -> prevLeft <= prevRight && lastLeft > lastRight
            Cross.DOWN -> prevLeft >= prevRight && lastLeft < lastRight
        }
    }

    // B: بازه
    private fun between(value: Double?, min: Double, max: Double): Boolean {
        if (value == null) return false
        return value in min..max
    }

    // لینک TradingView
    private fun buildTradingViewUrl(symbol: String, timeframe: String): String {
        val map = mapOf("1m" to "1","3m" to "3","5m" to "5","15m" to "15","1h" to "60","4h" to "240","1d" to "D","1w" to "W")
        val tf = map[timeframe] ?: "5"
        return "https://www.tradingview.com/chart/?symbol=BINANCE:$symbol&interval=$tf"
    }

    // نوتیفیکیشن با صدا/ویبره/نور
    private fun showAlertNotification(ctx: Context, symbol: String, timeframe: String, chartUrl: String) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(chartUrl)).apply {
            addFlags(Intent.FLAGACTIVITYNEWTASK or Intent.FLAGACTIVITYCLEARTOP)
        }
        val pending = android.app.PendingIntent.getActivity(
            ctx, 0, intent,
            android.app.PendingIntent.FLAGUPDATECURRENT or android.app.PendingIntent.FLAG_IMMUTABLE
        )

        val notif = NotificationCompat.Builder(ctx, "alerts")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("سیگنال فعال شد")
            .setContentText("$symbol @ $timeframe")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setDefaults(NotificationCompat.DEFAULT_ALL) // صدا، ویبره، چراغ
            .setContentIntent(pending)
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(ctx).notify(System.currentTimeMillis().toInt(), notif)
    }

    // نگاشت تایم‌فریم به ثانیه
    private fun mapTfToSeconds(tf: String): Int = when (tf) {
        "1m" -> 60
        "3m" -> 180
        "5m" -> 300
        "15m" -> 900
        "1h" -> 3600
        "4h" -> 14400
        "1d" -> 86400
        else -> 60
    }
}

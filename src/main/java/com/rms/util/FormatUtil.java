package com.rms.util;

import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

/**
 * Tiện ích định dạng dữ liệu và bảo vệ XSS trên trang JSP.
 */
public class FormatUtil {
    private static final Locale VI_LOCALE = Locale.forLanguageTag("vi-VN");

    public static String escapeHtml(String input) {
        if (input == null) {
            return "";
        }
        return input.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

    public static String formatCurrency(float amount) {
        NumberFormat nf = NumberFormat.getInstance(VI_LOCALE);
        nf.setMaximumFractionDigits(0);
        return nf.format(amount) + " VNĐ";
    }

    public static String formatDateTime(Date date) {
        if (date == null) {
            return "";
        }
        return new SimpleDateFormat("dd/MM/yyyy HH:mm").format(date);
    }
}

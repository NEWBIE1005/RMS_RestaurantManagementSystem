package com.rms.launcher;

import java.io.File;
import org.apache.catalina.Context;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;
import com.rms.dao.DAO;

/**
 * Embedded Tomcat 9 launcher phục vụ chạy và kiểm thử trực tiếp ứng dụng Web RMS.
 */
public class LocalTomcatServer {
    public static void main(String[] args) throws Exception {
        int port = Integer.parseInt(System.getProperty("rms.port", "8080"));
        String webappDir = new File("src/main/webapp").getAbsolutePath();
        String classesDir = new File("target/classes").getAbsolutePath();
        String workDir = new File("target/tomcat-work").getAbsolutePath();
        new File(workDir).mkdirs();

        // Mặc định dùng H2 dạng file cục bộ để lưu trữ bền vững dữ liệu thực tế (trừ khi truyền mysql hoặc rms.db.url)
        if (System.getProperty("rms.db.url") == null
                && !"mysql".equalsIgnoreCase(System.getProperty("rms.db.mode"))) {
            File dataDir = new File("data");
            if (!dataDir.exists()) {
                dataDir.mkdirs();
            }
            String fileDbUrl = "jdbc:h2:file:" + new File(dataDir, "rms_db").getAbsolutePath().replace('\\', '/')
                    + ";MODE=MySQL;DATABASE_TO_LOWER=TRUE;AUTO_SERVER=TRUE";
            System.setProperty("rms.db.url", fileDbUrl);
        }

        // Khởi tạo kết nối CSDL & dữ liệu mẫu trước khi mở HTTP server
        DAO.initConnection();

        Tomcat tomcat = new Tomcat();
        tomcat.setPort(port);
        tomcat.setBaseDir(workDir);
        tomcat.getConnector();

        Context ctx = tomcat.addWebapp("/rms", webappDir);
        ctx.setReloadable(true);

        WebResourceRoot resources = new StandardRoot(ctx);
        resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes", classesDir, "/"));
        ctx.setResources(resources);

        tomcat.start();
        System.out.println("====================================================");
        System.out.println("RMS Web Server started at: http://localhost:" + port + "/rms/");
        System.out.println("====================================================");
        tomcat.getServer().await();
    }
}

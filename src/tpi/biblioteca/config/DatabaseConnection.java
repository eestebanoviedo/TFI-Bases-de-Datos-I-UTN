package tpi.biblioteca.config;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DatabaseConnection {

    private static final String PROPERTIES_FILE = "/config.properties";
    private static String url;
    private static String user;
    private static String password;

    static {
        try (InputStream in = DatabaseConnection.class.getResourceAsStream(PROPERTIES_FILE)) {
            Properties props = new Properties();
            if (in == null) {
                throw new RuntimeException("No se encontró " + PROPERTIES_FILE);
            }
            props.load(in);
            url = props.getProperty("db.url");
            user = props.getProperty("db.user");
            password = props.getProperty("db.password");
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (IOException | ClassNotFoundException e) {
            throw new RuntimeException("Error cargando configuración de BD", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }
}

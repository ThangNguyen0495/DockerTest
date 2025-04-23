import org.testng.Assert;

import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;
import java.util.Optional;
import java.util.Properties;
import java.util.ResourceBundle;

/**
 * Utility class for loading and retrieving properties from a configuration file.
 */
public class PropertiesUtils {
    private static final String ENV_PROPERTIES_FILE = "config.properties";
    private static final Properties envProperties = new Properties();

    static {
        try (InputStream input = PropertiesUtils.class.getClassLoader().getResourceAsStream(ENV_PROPERTIES_FILE)) {
            if (input == null) {
                throw new RuntimeException("Unable to find " + ENV_PROPERTIES_FILE);
            }
            // Load the properties file from the class path
            envProperties.load(input);
        } catch (IOException ex) {
            throw new RuntimeException("Failed to load properties file: " + ENV_PROPERTIES_FILE, ex);
        }
    }

    /**
     * Retrieves the value associated with the specified key from the dashboard properties
     * for the specified language key.
     *
     * @param key     The key for the desired property.
     * @param langKey The language key to determine which language-specific properties file to load.
     * @return The property value as a String, or null if the key is not found.
     */
    public static String getDashboardProperty(String key, String langKey) {
        Assert.assertTrue(
                langKey.contains("en") || langKey.equals("vi"),
                "LangKey must be 'en' (English) or 'vi' (Vietnamese)"
        );
        Locale locale = Locale.forLanguageTag(langKey); // "en" for English, "vi" for Vietnamese
        ResourceBundle bundle = ResourceBundle.getBundle("localization/dashboard", locale);
        return bundle.getString(key);
    }

    /**
     * Retrieves the value associated with the specified key from the storefront properties
     * for the specified language key.
     *
     * @param key     The key for the desired property.
     * @param langKey The language key to determine which language-specific properties file to load.
     * @return The property value as a String, or null if the key is not found.
     */
    public static String getStorefrontProperty(String key, String langKey) {
        Locale locale = Locale.forLanguageTag(langKey); // "en" for English, "vi" for Vietnamese
        ResourceBundle bundle = ResourceBundle.getBundle("localization/dashboard", locale);
        return bundle.getString(key);
    }

    /**
     * Retrieves the property value for the given key.
     *
     * @param key The property key.
     * @return The property value, or null if the key does not exist.
     */
    private static String getProperty(String key) {
        return envProperties.getProperty(key);
    }

    /**
     * Retrieves the environment setting from configuration properties.
     *
     * @return The environment setting value.
     */
    public static String getEnv() {
        return getProperty("env");
    }

    /**
     * Retrieves the domain property value.
     *
     * @return The domain property value.
     */
    public static String getDomain() {
        return getProperty("domain");
    }

    /**
     * Retrieves the API host property value.
     *
     * @return The API host property value.
     */
    public static String getAPIHost() {
        return getProperty("apiHost");
    }

    /**
     * Retrieves the language key property value. If not found, defaults to "vi".
     *
     * @return The language key property value or "vi" if not set.
     */
    public static String getLangKey() {
        return Optional.ofNullable(getProperty("langKey")).orElse("vi");
    }

    /**
     * Retrieves the browser property value.
     *
     * @return The browser property value.
     */
    public static String getBrowser() {
        return getProperty("browser");
    }

    /**
     * Retrieves the headless property value.
     *
     * @return true if headless mode is enabled; false otherwise.
     */
    public static boolean getHeadless() {
        String headlessProperty = getProperty("headless");
        return Boolean.parseBoolean(headlessProperty);
    }
    /**
     * Retrieves the value of the "enableProxy" property and returns it as a boolean.
     *
     * @return {@code true} if the "enableProxy" property is set to "true", {@code false} otherwise.
     */
    public static boolean getEnableProxy() {
        return Boolean.parseBoolean(getProperty("enableProxy"));
    }

    public static String getAndroidEmulatorUdid() {
        return getProperty("androidEmulatorUdid");
    }

    public static String getAndroidSellerAppURL() {
        return getProperty("androidSELLERApp");
    }

    public static String getAndroidBuyerAppURL() {
        return getProperty("androidBUYERApp");
    }

    public static String getIOSSimulatorUdid() {
        return getProperty("iosUDID");
    }

    public static String getIOSSellerAppURL() {
        return getProperty("iosSELLERApp");
    }

    public static String getIOSBuyerAppURL() {
        return getProperty("iosBUYERApp");
    }
}

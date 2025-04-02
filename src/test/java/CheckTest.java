import org.testng.annotations.Test;

import java.net.MalformedURLException;
import java.net.URISyntaxException;

public class CheckTest {
    @Test
    void test() throws MalformedURLException, URISyntaxException {
        WebDriverManager.getAndroidDriver("emulator-5554", "");
    }

//    @Test
//    void test_actions() throws MalformedURLException, URISyntaxException {
//        WebDriverManager.getAndroidDriver("emulator-5554", "");
//    }
}

import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

public class CheckTest {
    @Test
    void test() throws IOException, URISyntaxException {

        WebDriverManager.getWebDriver();
    }
}

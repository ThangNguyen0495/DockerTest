import org.apache.logging.log4j.LogManager;
import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

public class CheckTest {
    @Test
    void test() throws IOException, URISyntaxException, InterruptedException {
        LogManager.getLogger().info("Start emulator and appium by bash scripts");
        ProcessBuilder pb = new ProcessBuilder("bash", "entrypoint.sh");
        pb.inheritIO();
        pb.start().waitFor();

        WebDriverManager.getAndroidDriver("emulator-5554", "");
    }

//    @AfterTest
//    void tearDown() throws IOException {
//        ProcessBuilder pb = new ProcessBuilder("bash", "-c", "pkill -f emulator && pkill -f appium");
//        pb.inheritIO();
//        pb.start();
//    }
}

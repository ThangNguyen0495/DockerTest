import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

public class CheckTest {
    @Test
    void test() throws IOException, URISyntaxException, InterruptedException {
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

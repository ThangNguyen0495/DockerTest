import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

public class CheckTest {
    @Test
    void test() throws IOException, URISyntaxException, InterruptedException {
        ProcessBuilder pb = new ProcessBuilder("bash", "entrypoint.sh");
        pb.inheritIO(); // to print logs
        Process process = pb.start();
        process.waitFor();
        WebDriverManager.getAndroidDriver("emulator-5554", "");
    }

//    @Test
//    void test_actions() throws MalformedURLException, URISyntaxException {
//        WebDriverManager.getAndroidDriver("emulator-5554", "");
//    }
}

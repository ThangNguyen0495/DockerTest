import java.io.BufferedInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * A utility class for downloading files from a URL and saving them to a specified local path.
 */
public class FileDownloadHelper {

    /**
     * Downloads a file from the given URL and saves it to the specified destination.
     *
     * @param fileUrl        The URL of the file to be downloaded. Must be a valid URI format.
     * @param destinationPath The local path where the file will be saved. If the directory does not exist, it will be created.
     * @throws IOException        If an I/O error occurs during the file download or save process.
     * @throws RuntimeException   If the provided URL is not a valid URI.
     */
    public static void downloadFile(String fileUrl, String destinationPath) throws IOException {
        // Validate and parse the destination path
        Path destination = Paths.get(destinationPath);
        Files.createDirectories(destination.getParent());

        // Open the URL stream and download the file
        try (BufferedInputStream in = new BufferedInputStream(new URI(fileUrl).toURL().openStream());
             FileOutputStream fileOutputStream = new FileOutputStream(destination.toFile())) {

            byte[] dataBuffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = in.read(dataBuffer)) != -1) {
                fileOutputStream.write(dataBuffer, 0, bytesRead);
            }
        } catch (URISyntaxException e) {
            throw new RuntimeException("Invalid URL format: " + fileUrl, e);
        }
    }
}

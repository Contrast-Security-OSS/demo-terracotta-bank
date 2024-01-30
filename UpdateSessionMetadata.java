import java.io.*;
import java.util.Map;

public class UpdateSessionMetadata {

    public static void main(String[] args) {
        try {
            String repositoryPath = "."; // Current directory
            String yamlFile = "contrast_security.yaml";

            // Get the combined information
            String combinedInfo = getGitInfo(repositoryPath);

            // Update the session_metadata in the YAML file
            if (combinedInfo != null) {
                updateSessionMetadata(yamlFile, combinedInfo);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String getGitInfo(String repositoryPath) {
        try {
            Process process = Runtime.getRuntime().exec("git rev-parse --abbrev-ref HEAD");
            String branch = readProcessOutput(process).trim();

            process = Runtime.getRuntime().exec("git rev-parse HEAD");
            String commitHash = readProcessOutput(process).trim();

            process = Runtime.getRuntime().exec("git config user.name");
            String committerName = readProcessOutput(process).trim();

            process = Runtime.getRuntime().exec("git config --get remote.origin.url");
            String remoteUrl = readProcessOutput(process).trim();

            // Combine all values into a single string
            return String.format("branchName=%s,commitHash=%s,committer=%s,repository=%s,environment=dev",
                    branch, commitHash, committerName, remoteUrl);
        } catch (IOException e) {
            System.err.println("An error occurred: " + e.getMessage());
            return null;
        }
    }

    private static void updateSessionMetadata(String yamlFile, String combinedInfo) {
        try {
            BufferedReader reader = new BufferedReader(new FileReader(yamlFile));
            StringBuilder content = new StringBuilder();
            String line;

            while ((line = reader.readLine()) != null) {
                if (line.contains("session_metadata")) {
                    line = "  session_metadata: " + combinedInfo;
                }
                content.append(line).append("\n");
            }
            reader.close();

            FileWriter writer = new FileWriter(yamlFile);
            writer.write(content.toString());
            writer.close();

            System.out.println("Updated session_metadata in '" + yamlFile + "'");
        } catch (IOException e) {
            System.err.println("An error occurred: " + e.getMessage());
        }
    }

    private static String readProcessOutput(Process process) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
        String line = reader.readLine();
        reader.close();
        return line;
    }
}

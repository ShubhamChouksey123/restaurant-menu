package com.bapukikutia.menuadmin.service;

import com.bapukikutia.menuadmin.config.GitConfig;
import com.bapukikutia.menuadmin.exception.GitOperationException;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.eclipse.jgit.api.Git;
import org.eclipse.jgit.api.PullResult;
import org.eclipse.jgit.api.PushCommand;
import org.eclipse.jgit.api.errors.GitAPIException;
import org.eclipse.jgit.transport.UsernamePasswordCredentialsProvider;
import org.springframework.stereotype.Service;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Slf4j
@Service
@RequiredArgsConstructor
public class GitService {

    private final GitConfig gitConfig;
    private Git git;
    private UsernamePasswordCredentialsProvider credentialsProvider;

    @PostConstruct
    public void initialize() {
        log.info("Initializing Git service...");

        // Set up credentials
        credentialsProvider = new UsernamePasswordCredentialsProvider(
                gitConfig.getRepository().getUsername(),
                gitConfig.getRepository().getToken()
        );

        try {
            File localPath = new File(gitConfig.getLocal().getCloneDirectory());

            if (localPath.exists() && new File(localPath, ".git").exists()) {
                log.info("Repository already exists at: {}", localPath.getAbsolutePath());
                git = Git.open(localPath);
                pullLatestChanges();
            } else {
                log.info("Cloning repository to: {}", localPath.getAbsolutePath());
                cloneRepository(localPath);
            }

            log.info("Git service initialized successfully");
        } catch (Exception e) {
            log.error("Failed to initialize Git repository", e);
            throw new GitOperationException("Failed to initialize Git repository: " + e.getMessage(), e);
        }
    }

    private void cloneRepository(File localPath) throws GitAPIException {
        git = Git.cloneRepository()
                .setURI(gitConfig.getRepository().getUrl())
                .setDirectory(localPath)
                .setBranch(gitConfig.getRepository().getBranch())
                .setCredentialsProvider(credentialsProvider)
                .call();

        log.info("Repository cloned successfully");
    }

    public void pullLatestChanges() {
        try {
            log.info("Pulling latest changes from remote repository...");
            PullResult result = git.pull()
                    .setCredentialsProvider(credentialsProvider)
                    .call();

            if (result.isSuccessful()) {
                log.info("Pull successful");
            } else {
                log.warn("Pull completed with issues: {}", result.toString());
            }
        } catch (GitAPIException e) {
            log.error("Failed to pull changes", e);
            throw new GitOperationException("Failed to pull latest changes: " + e.getMessage(), e);
        }
    }

    public void commitAndPush(String commitMessage) {
        try {
            log.info("Committing changes with message: {}", commitMessage);

            // Add all changes
            git.add()
                    .addFilepattern(gitConfig.getMenu().getFilePath())
                    .call();

            // Commit
            git.commit()
                    .setMessage(commitMessage)
                    .call();

            log.info("Changes committed successfully");

            // Push to remote
            log.info("Pushing changes to remote repository...");
            PushCommand pushCommand = git.push()
                    .setCredentialsProvider(credentialsProvider)
                    .setRemote("origin")
                    .add(gitConfig.getRepository().getBranch());

            pushCommand.call();
            log.info("Changes pushed successfully to {}", gitConfig.getRepository().getBranch());

        } catch (GitAPIException e) {
            log.error("Failed to commit and push changes", e);
            throw new GitOperationException("Failed to commit and push changes: " + e.getMessage(), e);
        }
    }

    public Path getMenuFilePath() {
        return Paths.get(
                gitConfig.getLocal().getCloneDirectory(),
                gitConfig.getMenu().getFilePath()
        );
    }

    public String readMenuFile() {
        try {
            Path menuPath = getMenuFilePath();
            if (!Files.exists(menuPath)) {
                throw new GitOperationException("Menu file not found at: " + menuPath);
            }
            return Files.readString(menuPath);
        } catch (IOException e) {
            log.error("Failed to read menu file", e);
            throw new GitOperationException("Failed to read menu file: " + e.getMessage(), e);
        }
    }

    public void writeMenuFile(String content) {
        try {
            Path menuPath = getMenuFilePath();
            Files.writeString(menuPath, content);
            log.info("Menu file updated at: {}", menuPath);
        } catch (IOException e) {
            log.error("Failed to write menu file", e);
            throw new GitOperationException("Failed to write menu file: " + e.getMessage(), e);
        }
    }

    public void close() {
        if (git != null) {
            git.close();
            log.info("Git repository closed");
        }
    }
}

package com.bapukikutia.menuadmin.controller;

import com.bapukikutia.menuadmin.dto.AuthRequest;
import com.bapukikutia.menuadmin.dto.AuthResponse;
import com.bapukikutia.menuadmin.model.User;
import com.bapukikutia.menuadmin.security.JwtUtil;
import com.bapukikutia.menuadmin.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
@CrossOrigin(origins = "${cors.allowed-origins}")
public class AuthController {

    private final AuthenticationManager authenticationManager;
    private final JwtUtil jwtUtil;
    private final UserService userService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody AuthRequest authRequest) {
        try {
            log.info("Login attempt for user: {}", authRequest.getUsername());

            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            authRequest.getUsername(),
                            authRequest.getPassword()
                    )
            );

            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            String token = jwtUtil.generateToken(userDetails);

            User user = userService.findByUsername(authRequest.getUsername());
            AuthResponse response = AuthResponse.of(token, user.getUsername(), user.getEmail());

            log.info("User logged in successfully: {}", authRequest.getUsername());
            return ResponseEntity.ok(response);

        } catch (BadCredentialsException e) {
            log.warn("Failed login attempt for user: {}", authRequest.getUsername());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body("Invalid username or password");
        }
    }

    @GetMapping("/validate")
    public ResponseEntity<?> validateToken() {
        log.info("Token validation request");
        return ResponseEntity.ok("Token is valid");
    }
}

package com.example.SpringBoot_BE.Controller;

import com.example.SpringBoot_BE.JwtUtils;
import com.example.SpringBoot_BE.Model.PasswordResetToken;
import com.example.SpringBoot_BE.Model.Role;
import com.example.SpringBoot_BE.Model.User;
import com.example.SpringBoot_BE.Repository.PasswordResetTokenRepository;
import com.example.SpringBoot_BE.Repository.RoleRepository;
import com.example.SpringBoot_BE.Repository.UserRepository;
import com.example.SpringBoot_BE.Service.EmailService;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class AuthController {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordResetTokenRepository passwordResetTokenRepository;
    private final EmailService emailService;

    private final JwtUtils jwtUtils;
    private final PasswordEncoder passwordEncoder = new BCryptPasswordEncoder();

    // ------------------- REGISTER -------------------
    @PostMapping("/register")
    public ResponseEntity<?> register(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String password = body.get("password");

        if (userRepository.findByEmail(email).isPresent()) {
            return ResponseEntity.badRequest().body("Email already exists");
        }

        User user = new User();
        user.setEmail(email);
        user.setPassword(passwordEncoder.encode(password));

        Role userRole = roleRepository.findByName("user")
                .orElseThrow(() -> new RuntimeException("Role 'user' not found"));
        user.setRole(userRole);

        userRepository.save(user);

        String token = jwtUtils.generateJwtToken(user.getEmail());
        return ResponseEntity.ok(Map.of("message", "Register success", "token", token, "user", user));
    }

    // ------------------- LOGIN -------------------
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String email = body.get("email");
        String password = body.get("password");

        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(password, user.getPassword())) {
            return ResponseEntity.badRequest().body("Wrong password");
        }

        String token = jwtUtils.generateJwtToken(user.getEmail());
        return ResponseEntity.ok(Map.of("message", "Login successful", "token", token, "user", user));
    }

    // ------------------- SOCIAL LOGIN -------------------
    @PostMapping("/login/social")
    public ResponseEntity<?> socialLogin(@RequestBody Map<String, String> body) {
        String idToken = body.get("id_token");

        try {
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            String uid = decodedToken.getUid();
            String email = decodedToken.getEmail();
            String fullName = (String) decodedToken.getClaims().get("name");
            String avatarUrl = (String) decodedToken.getClaims().get("picture");
            String provider = body.get("provider");

            User user = userRepository.findBySocialProviderAndSocialId(provider, uid)
                    .orElseGet(() -> {
                        User existing = (email != null) ? userRepository.findByEmail(email).orElse(null) : null;
                        if (existing != null) {
                            existing.setSocialProvider(provider);
                            existing.setSocialId(uid);
                            existing.setFullName(fullName);
                            existing.setAvatarUrl(avatarUrl);
                            return userRepository.save(existing);
                        }

                        User newUser = new User();
                        newUser.setSocialProvider(provider);
                        newUser.setSocialId(uid);
                        newUser.setEmail(email);
                        newUser.setFullName(fullName);
                        newUser.setAvatarUrl(avatarUrl);

                        Role userRole = roleRepository.findByName("user")
                                .orElseThrow(() -> new RuntimeException("Role 'user' not found"));
                        newUser.setRole(userRole);

                        return userRepository.save(newUser);
                    });

            String token = jwtUtils.generateJwtToken(user.getEmail());
            return ResponseEntity.ok(Map.of("message", "Social login successful", "token", token, "user", user));

        } catch (FirebaseAuthException e) {
            return ResponseEntity.status(401).body("Invalid Firebase token");
        }
    }

    // ------------------- FORGOT PASSWORD -------------------
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> body) throws MessagingException {
        String email = body.get("email");
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("User not found"));

        String token = UUID.randomUUID().toString();
        PasswordResetToken resetToken = PasswordResetToken.builder()
                .token(token)
                .user(user)
                .expiryDate(LocalDateTime.now().plusHours(1))
                .build();

        passwordResetTokenRepository.save(resetToken);

        String link = "http://localhost:8080/api/reset-password?token=" + token;
        emailService.sendMail(email, "Reset Password", "Click here to reset: " + link);

        return ResponseEntity.ok("Reset link sent");
    }

    // ------------------- RESET PASSWORD -------------------
    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> body) {
        String token = body.get("token");
        String newPassword = body.get("new_password");

        PasswordResetToken resetToken = passwordResetTokenRepository.findByToken(token)
                .orElseThrow(() -> new RuntimeException("Invalid token"));

        if (resetToken.getExpiryDate().isBefore(LocalDateTime.now())) {
            return ResponseEntity.badRequest().body("Token expired");
        }

        User user = resetToken.getUser();
        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        passwordResetTokenRepository.delete(resetToken);

        return ResponseEntity.ok("Password reset successful");
    }
}

package com.example.demo.api;

import com.example.demo.domain.User;
import com.example.demo.domain.UserRepository;
import com.example.demo.exception.user.UserNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
public class UserController {
    @Autowired
    private UserRepository userRepository;

    @PostMapping("/api/v1/user")
    public User create(@RequestBody User user) {
        return userRepository.save(user);
    }

    @GetMapping("/api/v1/user")
    public @ResponseBody Iterable<User> getAllUsers() {
        // This returns a JSON or XML with the users
        return userRepository.findAll();
    }

    @GetMapping("/api/v1/user/{id}")
    public User retrieve(@PathVariable("id") Long id) {

        return userRepository.findById(id)
                .orElseThrow(() -> new UserNotFoundException(id));
    }

    @PutMapping("/api/v1/user/{id}")
    public User update(@RequestBody User user, @PathVariable Long id) {
        user.setId(id);
        return userRepository.save(user);
    }

    @DeleteMapping("/api/v1/user/{id}")
    void delete(@PathVariable Long id) {
        userRepository.deleteById(id);
    }
}

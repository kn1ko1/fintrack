// backend/go_services/auth/main.go

package main

import (
	"log"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	r := mux.NewRouter()

	// API routes will be defined here
	r.HandleFunc("/api/auth/register", RegisterHandler).Methods("POST")
	r.HandleFunc("/api/auth/login", LoginHandler).Methods("POST")
	r.HandleFunc("/api/auth/refresh", RefreshTokenHandler).Methods("POST")
	r.HandleFunc("/api/auth/verify", VerifyTokenHandler).Methods("POST")

	// Set up middleware
	r.Use(loggingMiddleware)

	// Start server
	log.Println("Authentication service starting on :8081")
	log.Fatal(http.ListenAndServe(":8081", r))
}

// Placeholder handlers - to be implemented
func RegisterHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"message": "Register endpoint"}`))
}

func LoginHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"message": "Login endpoint"}`))
}

func RefreshTokenHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"message": "Refresh token endpoint"}`))
}

func VerifyTokenHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"message": "Verify token endpoint"}`))
}

// Middleware for logging
func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Request: %s %s", r.Method, r.URL.Path)
		next.ServeHTTP(w, r)
	})
}

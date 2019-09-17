package main

import (
	"net/http"
	"encoding/json"
	"os"
)

func main() {
	http.HandleFunc("/api/hello", HelloFunc)
	http.ListenAndServe(port(), nil)
}

func port() string {
	port := os.Getenv("PORT")
	if len(port) == 0 {
		port = "8080"
	}
	return ":" + port
}

// Hello response structure
type Hello struct {
	Message string
}

// HelloFunc to be used as http.HandleFunc for Hello API
func HelloFunc(w http.ResponseWriter, r *http.Request) {
	m := Hello{"Hello Service v1."}
  b, err := json.Marshal(m)

  if err != nil {
		panic(err)
  }

  w.Header().Add("Content-Type", "application/json; charset=utf-8")
  w.Write(b)
}

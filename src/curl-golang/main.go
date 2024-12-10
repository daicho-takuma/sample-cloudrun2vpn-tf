package main

import (
	"fmt"
	"io"
	"net/http"
	"os"
)

func handler(w http.ResponseWriter, r *http.Request) {
	// 特定のIPアドレスを取得
	targetIP := os.Getenv("TARGET_IP")
	if targetIP == "" {
		http.Error(w, "TARGET_IP environment variable is not set", http.StatusInternalServerError)
		return
	}

	// URLを構築
	url := fmt.Sprintf("http://%s", targetIP)

	// HTTPリクエストの実行
	resp, err := http.Get(url)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error fetching URL: %v", err), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// レスポンスボディの読み取り
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error reading response body: %v", err), http.StatusInternalServerError)
		return
	}

	// 結果を返す
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"status_code": %d, "body": %q}`, resp.StatusCode, string(body))
}

func main() {
	http.HandleFunc("/", handler)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	http.ListenAndServe(":"+port, nil)
}

package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", handleRequest)

	// ポート設定（Cloud Run用にPORT環境変数を使用）
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Server starting on port %s...", port)
	log.Fatal(http.ListenAndServe(":"+port, nil))
}

func handleRequest(w http.ResponseWriter, r *http.Request) {
	// 環境変数でターゲットURLを取得
	targetURL := os.Getenv("TARGET_URL")
	if targetURL == "" {
		http.Error(w, "TARGET_URL environment variable not set", http.StatusInternalServerError)
		return
	}

	// HTTPリクエストを送信
	resp, err := http.Get(targetURL)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error making request: %v", err), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// レスポンスを読み込む
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, fmt.Sprintf("Error reading response: %v", err), http.StatusInternalServerError)
		return
	}

	// レスポンスステータスとボディを出力
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, `{"status": "%s", "body": %q}`, resp.Status, string(body))
}
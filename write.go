package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"time"
)

func main() {

	clustername := os.Getenv("CLUSTER_NAME")
	if clustername == "" {
		fmt.Println("CLUSTER_NAME environment variable not set")
		return
	}

	// Construct the request URL
	requestUrl := fmt.Sprintf("https://console-staging.mgmt-24.konstruct.io/api/proxy?url=/cluster/%s", clustername)

	// Make the GET request
	resp, err := http.Get(requestUrl)
	if err != nil {
		fmt.Printf("Error making request: %v\n", err)
		return
	}
	defer resp.Body.Close()

	// Parse the JSON response
	var responseBody map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&responseBody); err != nil {
		fmt.Printf("Error decoding response: %v\n", err)
		return
	}

	// Extract credentials
	gitAuth := responseBody["git_auth"].(map[string]interface{})
	gitOwner := gitAuth["git_owner"].(string)
	gitToken := gitAuth["git_token"].(string)
	gitUsername := gitAuth["git_username"].(string)
	subdomain := responseBody["subdomain_name"].(string)
	domain := responseBody["domain_name"].(string)

	fmt.Printf("Git Owner: %s\n", gitOwner)
	fmt.Printf("Git Token: %s\n", gitToken)
	fmt.Printf("Subdomain: %s\n", subdomain)
	fmt.Printf("Domain: %s\n", domain)

	time.Sleep(10 * time.Minute)
	cmd := fmt.Sprintf("./clone.sh %s %s %s %s", gitOwner, gitToken, gitUsername, clustername)

	command := exec.Command("/bin/sh", "-c", cmd)
	output, err := command.CombinedOutput() // Captures both stdout and stderr
	if err != nil {
		fmt.Printf("Error running command: %v\n", err)
		fmt.Printf("Command output: %s\n", string(output))
		return
	}

	// Print command output
	fmt.Printf("Command output: %s\n", string(output))

}

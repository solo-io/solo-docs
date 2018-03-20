package main

import (
	"fmt"
	"log"

	"github.com/spf13/cobra"
	apiv1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/rest"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/retry"
)

func main() {
	cmd().Execute()
}

func cmd() *cobra.Command {
	var kubeConfig string
	var deploymentName string
	var image string
	deployCmd := &cobra.Command{
		Use: "deploy",
		Run: func(c *cobra.Command, args []string) {
			deploy(kubeConfig, deploymentName, image)
		},
	}
	f := deployCmd.Flags()
	f.StringVar(&kubeConfig, "kubeconfig", "", "kubeconfig for out of cluster deploy")
	f.StringVarP(&image, "image", "i", "", "image to update to")
	f.StringVarP(&deploymentName, "name", "n", "gloo-docs", "deployment to update")
	deployCmd.MarkFlagRequired("image")

	cmd := &cobra.Command{
		Use:   "deployer",
		Short: "Deploy to Kubernetes",
	}
	cmd.AddCommand(deployCmd)
	return cmd
}

func deploy(kubeConfig, deploymentName, image string) {
	var config *rest.Config
	if kubeConfig != "" {
		var err error
		config, err = clientcmd.BuildConfigFromFlags("", kubeConfig)
		if err != nil {
			log.Fatalf("Unable to get configuration from %s: %q", kubeConfig, err)
		}
	} else {
		var err error
		config, err = rest.InClusterConfig()
		if err != nil {
			log.Fatalf("Unable to get configuration %q", err)
		}
	}

	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		log.Fatalf("Unable to get client: %q", err)
	}

	client := clientset.AppsV1beta1().Deployments(apiv1.NamespaceDefault)
	retryErr := retry.RetryOnConflict(retry.DefaultRetry, func() error {
		result, getErr := client.Get(deploymentName, metav1.GetOptions{})
		if getErr != nil {
			log.Fatalf("Failed to get latest version of deployment: %q", getErr)
		}
		result.Spec.Template.Spec.Containers[0].Image = image
		_, updateErr := client.Update(result)
		return updateErr
	})
	if retryErr != nil {
		log.Fatalf("Update failed: %q", retryErr)
	}
	fmt.Println("updated deployment")
}

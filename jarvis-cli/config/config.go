package config

import (
	"fmt"
	"github.com/spf13/viper"
)

type LoggingConfig struct {
	Level string
}

type DatabaseConfig struct {
	Connection string
}

type SecurityConfig struct {
	SecretKey string `mapstructure:"secret_key"`
}

type CliConfig struct {
	Logging  LoggingConfig
	Database DatabaseConfig
	Security SecurityConfig
}

func LoadConfig() {
	viper.SetConfigName("configuration")
	viper.SetConfigType("yaml")
	viper.AddConfigPath("/etc/jarvis/")
	viper.AddConfigPath("$HOME/.jarvis")
	viper.AddConfigPath(".")

	err := viper.ReadInConfig()

	if err != nil {
		panic(fmt.Errorf("fatal error config file: %w", err))
	}

	var config CliConfig

	err = viper.Unmarshal(&config)
	if err != nil {
		panic(fmt.Errorf("fatal error reading config: %w", err))
	}

	fmt.Printf("%s\n", config)
}

/*
Package cmd.

Copyright © 2022 Corka149 corka149@mailbox.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package cmd

import (
	"errors"
	"fmt"
	"github.com/corka149/jarvis/jarvis-cli/db"
	"github.com/corka149/jarvis/jarvis-cli/util"
	"github.com/spf13/cobra"
	"strings"
)

// passwdCmd represents the update command
var passwdCmd = &cobra.Command{
	Use:   "passwd",
	Short: "Updates password of an user",
	RunE:  runUserPasswd,
}

func init() {
	userCmd.AddCommand(passwdCmd)

	passwdCmd.Flags().StringVarP(&email, "email", "e", "", "E-Mail of user")
	passwdCmd.Flags().StringVarP(&password, "password", "p", "", "Password for accessing jARVIS")
}

func runUserPasswd(cmd *cobra.Command, args []string) error {
	if email == "" {
		e, err := util.RequestUser("email")
		if err != nil {
			return err
		}

		email = e
	}

	email = strings.TrimSpace(email)

	if len(email) == 0 {
		return errors.New("email is empty")
	}

	if password == "" {
		passwd, err := util.RequestUser("password")
		if err != nil {
			return err
		}

		password = passwd
	}
	password = strings.TrimSpace(password)

	if len(password) == 0 {
		return errors.New("empty passwords are not possible")
	}

	c, err := db.New()
	defer c.Disconnect()

	if err != nil {
		return err
	}

	err = c.UpdatePassword(email, password)

	if err == nil {
		fmt.Println("password updated")
	}

	return err
}

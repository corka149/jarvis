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
	"net/mail"
	"strings"
)

// addUserCmd represents the add command
var addUserCmd = &cobra.Command{
	Use:   "add",
	Short: "Adds a new user",
	RunE:  runAddUser,
}

func init() {
	userCmd.AddCommand(addUserCmd)

	addUserCmd.Flags().StringVarP(&orgaName, "organization", "o", "", "Name of the organization to which the user shall belong")
	addUserCmd.Flags().StringVarP(&userName, "name", "n", "", "Name of the new user")
	addUserCmd.Flags().StringVarP(&email, "email", "e", "", "E-Mail of the new user")
	addUserCmd.Flags().StringVarP(&password, "password", "p", "", "Password for accessing jARVIS")
}

func runAddUser(cmd *cobra.Command, args []string) error {
	if orgaName == "" {
		name, err := util.RequestUser("organization name")
		if err != nil {
			return err
		}

		orgaName = name
	}
	orgaName = strings.TrimSpace(orgaName)

	if userName == "" {
		name, err := util.RequestUser("user name")
		if err != nil {
			return err
		}

		userName = name
	}
	userName = strings.TrimSpace(userName)

	if email == "" {
		name, err := util.RequestUser("e-mail")
		if err != nil {
			return err
		}

		email = name
	}
	email = strings.TrimSpace(email)

	_, err := mail.ParseAddress(email)
	if err != nil {
		return err
	}

	if password == "" {
		passwd, err := util.RequestUser("password")
		if err != nil {
			return err
		}

		password = passwd
	}
	password = strings.TrimSpace(password)

	c, err := db.New()
	defer c.Disconnect()

	if err != nil {
		return err
	}

	user, err := c.GetUser(email)
	if err != nil {
		return err
	}

	if user != nil {
		return errors.New("user with the given email already exists")
	}

	orga, err := c.GetOrga(orgaName)
	if err != nil {
		return err
	}

	if orga == nil {
		text := fmt.Sprintf("no organization with name %s exists", orgaName)
		return errors.New(text)
	}

	newUuid, err := c.AddUser(userName, email, password, *orga)
	if err != nil {
		return err
	}

	fmt.Printf("user was added with uuid %s\n", *newUuid)

	return nil
}

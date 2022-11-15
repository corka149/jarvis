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

var (
	// addOrgaCmd represents the add command
	addOrgaCmd = &cobra.Command{
		Use:   "add",
		Short: "Adds a new organisation",
		RunE: func(cmd *cobra.Command, args []string) error {
			return runOrgaAdd()
		},
	}

)

func init() {
	orgaCmd.AddCommand(addOrgaCmd)

	addOrgaCmd.Flags().StringVarP(&orgaName, "name", "n", "", "Name of the new organization")
}

func runOrgaAdd() error {
	if orgaName == "" {
		name, err := util.RequestUser("organization name")
		if err != nil {
			return err
		}

		orgaName = name
	}

	orgaName = strings.TrimSpace(orgaName)

	if len(orgaName) == 0 {
		return errors.New("organization name is empty")
	}

	c, err := db.New()
	defer c.Disconnect()

	if err != nil {
		return err
	}

	orga, err := c.GetOrga(orgaName)
	if err != nil {
		return err
	}

	if orga != nil {
		return errors.New("organization with this name already exists")
	}

	newUuid, err := c.AddOrga(orgaName)

	fmt.Printf("Organization was added with uuid %s\n", *newUuid)

	return nil
}

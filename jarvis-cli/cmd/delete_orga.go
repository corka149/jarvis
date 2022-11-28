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

// deleteOrgaCmd represents the delete command
var deleteOrgaCmd = &cobra.Command{
	Use:   "delete",
	Short: "Deletes an existing organisation",
	RunE:  runOrgaDelete,
}

func init() {
	orgaCmd.AddCommand(deleteOrgaCmd)

	deleteOrgaCmd.Flags().StringVarP(&orgaName, "name", "n", "", "Name of the new organization")
}

func runOrgaDelete(cmd *cobra.Command, args []string) error {
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
	if orga == nil {
		return errors.New("no organization exists with this name")
	}

	if err = c.DeleteOrga(orgaName); err != nil {
		return err
	}

	fmt.Printf("Delete organization %s\n", orgaName)

	return nil
}

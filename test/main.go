package main

import (
	"fmt"
	"log"
	"strings"
	"text/tabwriter"

	"github.com/davecgh/go-spew/spew"
	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclwrite"
	"github.com/ktr0731/go-fuzzyfinder"
	"github.com/zclconf/go-cty/cty"

	"golang.org/x/net/context"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/cloudresourcemanager/v1"
)

func _main() {
	f := hclwrite.NewEmptyFile()
	rootBody := f.Body()
	rootBody.SetAttributeValue("string", cty.StringVal("bar")) // this is overwritten later
	rootBody.AppendNewline()
	rootBody.SetAttributeValue("object", cty.ObjectVal(map[string]cty.Value{
		"baz": cty.True,
		"bar": cty.NumberIntVal(5),
		"foo": cty.StringVal("foo"),
	}))
	rootBody.SetAttributeValue("string", cty.StringVal("foo"))
	rootBody.SetAttributeValue("bool", cty.False)
	rootBody.SetAttributeTraversal("path", hcl.Traversal{
		hcl.TraverseRoot{
			Name: "env",
		},
		hcl.TraverseAttr{
			Name: "PATH",
		},
	})
	rootBody.AppendNewline()
	fooBlock := rootBody.AppendNewBlock("foo", nil)
	fooBody := fooBlock.Body()
	rootBody.AppendNewBlock("empty", nil)
	rootBody.AppendNewline()
	barBlock := rootBody.AppendNewBlock("bar", []string{"a", "b"})
	barBody := barBlock.Body()

	fooBody.SetAttributeValue("hello", cty.StringVal("world"))

	bazBlock := barBody.AppendNewBlock("baz", nil)
	bazBody := bazBlock.Body()
	bazBody.SetAttributeValue("foo", cty.NumberIntVal(10))
	bazBody.SetAttributeValue("beep", cty.StringVal("boop"))
	bazBody.SetAttributeValue("baz", cty.ListValEmpty(cty.String))

	fmt.Printf("%s", f.Bytes())
}

func main() {
	ctx := context.Background()

	c, err := google.DefaultClient(ctx, cloudresourcemanager.CloudPlatformScope)
	if err != nil {
		log.Fatal(err)
	}

	cloudresourcemanagerService, err := cloudresourcemanager.New(c)
	if err != nil {
		log.Fatal(err)
	}

	projects := []*cloudresourcemanager.Project{}
	req := cloudresourcemanagerService.Projects.List()
	if err := req.Pages(ctx, func(page *cloudresourcemanager.ListProjectsResponse) error {
		for _, project := range page.Projects {
			projects = append(projects, project)
		}
		return nil
	}); err != nil {
		log.Fatal(err)
	}

	idx, _ := fuzzyfinder.Find(projects,
		func(i int) string {
			return fmt.Sprintf("[%s] %s", projects[i].LifecycleState, projects[i].Name)
		},
		fuzzyfinder.WithPreviewWindow(func(i, _, _ int) string {
			if i == -1 {
				return "None selected!"
			}

			b := strings.Builder{}
			w := tabwriter.NewWriter(&b, 0, 1, 1, ' ', 0)

			fmt.Fprintf(w, "Project %s\n\n", projects[i].Name)
			fmt.Fprintf(w, "State:\t%s\n", projects[i].LifecycleState)
			fmt.Fprintf(w, "Id:\t%s\n", projects[i].ProjectId)
			fmt.Fprintf(w, "Name:\t%s\n", projects[i].Name)
			fmt.Fprintf(w, "Number:\t%d\n", projects[i].ProjectNumber)
			fmt.Fprintf(w, "Created:\t%s\n", projects[i].CreateTime)

			if len(projects[i].Labels) == 0 {
				fmt.Fprint(w, "Labels:\tNone\n")
			} else {
				fmt.Fprint(w, "Labels:\t")

				labelidx := 0
				for k, v := range projects[i].Labels {
					if labelidx == 0 {
						fmt.Fprintf(w, "%s=%s\n", k, v)
					} else {
						fmt.Fprintf(w, "\t%s=%s\n", k, v)
					}
					labelidx++
				}
			}

			w.Flush()
			_ = spew.Dump
			// spew.Fdump(&b, projects[i])
			return b.String()
		}),
	)

	fmt.Println("you found", projects[idx].Name)

	f := hclwrite.NewEmptyFile()
	rootBody := f.Body()

	localsBlock := rootBody.AppendNewBlock("locals", nil)
	localsBody := localsBlock.Body()
	localsBody.SetAttributeValue("region", cty.StringVal("test"))
	localsBody.SetAttributeValue("zone", cty.StringVal("test"))

	rootBody.AppendNewline()
	rootBody.SetAttributeValue("inputs", cty.ObjectVal(map[string]cty.Value{
		"google_project_id": cty.StringVal(projects[idx].Name),
	}))

	fmt.Printf("%s\n", f.Bytes())
}

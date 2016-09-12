# kubernetes-the-easy-way

This repo is based on [Kelsey Hightower's Kubernetes the Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way). Currently, it only builds the AWS infrastructure, but I hope to expand it, and I'm very open to PRs that help :).

## Usage

To build the AWS Infrastructure, you'll need a system with a modern Ruby environment with the Bundler gem & an IAM user that can build Cloudformation Stacks in us-west-2. You should also have an SSH Key in the AWS us-west-2 region.

Clone the repo, then do the following:

1. Export `AWS_ACCESS_KEY_ID` & `AWS_SECRET_ACCESS_KEY`.
2. `bundle install`
3. `bundle exec sfn create kubernetes-vpc --file kube_vpc`
4. `bundle exec sfn create kubernetes-instances --file kube_instances --apply-stack kubernetes-vpc`

If these are successful, you should have 9 AWS instances corresponding to the instances in Kelsey's guide.

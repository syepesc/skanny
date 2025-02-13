# Skanny

This application allows you to upload files either to AWS S3 using presign URL's or locally to disk using a friendly UI.

> A big shoutout to the Elixir Phoenix LiveView team! Their [Uploads](https://hexdocs.pm/phoenix_live_view/uploads.html) and [External Uploads](https://hexdocs.pm/phoenix_live_view/external-uploads.html) documentation made handling file uploads a breeze and significantly simplified the development of this application.

## Getting Started

- To start uploading files locally, please refer to the [How to run the project?](#how-to-run-the-project) section for instructions.

- If you want to upload files to AWS S3, there are some configuration steps you need to complete before running the application. Please refer to the [How to configure AWS S3 uploads?](#how-to-configure-aws-s3-uploads) section for more information.

## Modifying Upload Configuration

### Local Uploads Configuration

To change the configuration for local uploads, you need to modify the following module attributes in the `/skanny/lib/skanny_web/live/upload_to_disk_live.ex` file:

```elixir
@allowed_file_types ~w(.jpg .jpeg .pdf)
@max_file_size_in_bytes 100_000
@max_entries 2
@chunk_size_in_bytes 20
```

### AWS S3 Uploads Configuration

To change the configuration for AWS S3 uploads, you need to modify the following module attributes in the `/skanny/lib/skanny_web/live/upload_to_s3_live.ex` file:

```elixir
@allowed_file_types ~w(.jpg .jpeg .pdf)
@max_file_size_in_bytes 15_000_000
@max_entries 3
```

## How to configure AWS S3 uploads?

There are several ways to set up IAM users and roles for your S3 bucket, depending on how restrictive and organized you want to be. Here are the steps I used, but feel free to adjust them to suit your needs.

1. **Create an AWS Account**: If you don't already have an AWS account, you can [create one here](https://signin.aws.amazon.com/signup?request_type=register).

2. **Create an S3 Bucket**: Create a new S3 bucket named `skanny-bucket` and note the region where it's created. After creating the bucket, go to the `Permissions` tab and modify the bucket's CORS configuration with the following settings:

    ```json
    [
        {
            "AllowedHeaders": [
                "*"
            ],
            "AllowedMethods": [
                "PUT",
                "POST"
            ],
            "AllowedOrigins": [
                "*"
            ],
            "ExposeHeaders": []
        }
    ]
    ```

3. **Create an IAM User**: Go to IAM, create a new user, and assign the following policy to grant the least permissions necessary:

    ```json
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Action": [
                    "s3:PutObject"
                ],
                "Resource": "arn:aws:s3:::skanny-bucket/*"
            }
        ]
    }
    ```

4. **Generate Access Keys**: After creating the user, go to the `Security Credentials` tab and generate a `Access Key` for you command line interface (CLI). Save these keys for the next steps.

5. **Install AWS CLI**: Install the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) on your computer.

6. **Configure AWS CLI Profile**: Configure your [AWS CLI profile](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html#cli-configure-files-format-profile). The quickest way is to run `aws configure` and enter the credentials from step 4 and the region from step 2. Then, modify `~/.aws/credentials` and `~/.aws/config` to include your credentials under the profile `skanny`.

    Your files should look something like this:

    `~/.aws/credentials`

    ```text
    [skanny]
    aws_access_key_id=<your_access_key>
    aws_secret_access_key=<your_secret_access_key>
    ```

    `~/.aws/config`

    ```text
    [profile skanny]
    region=<your_bucket_region>
    output=json
    ```

7. **Run the Project**: Refer to the [How to run the project?](#how-to-run-the-project) section below to start the application.

## How to run the project?

-  Install [postgres](https://www.postgresql.org/download/), the app doesn't use a database but initially it was configured to do so.

- Install [mise](https://mise.jdx.dev/getting-started.html) (previously `rtx`) , `cd` into the project directory and run:

```bash
mise install
```

- `cd` into the project directory and run the following to install and setup dependencies:

```bash
mix setup
```

- Start Phoenix endpoint with

```bash
mix phx.server
```

OR inside IEx with

```bash
iex -S mix phx.server
```

> Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## How to run the tests of the project?

### Unit tests

- `cd` into the project directory and run:

```bash
mix test
```

### Integration tests

WIP.

### Smoke tests

WIP.

"""
This function uses AWS TextExtract to analyze and extract data from identity documents, like:
- Passports
- Driver's Licenses
- Health Insurance Cards
- Social Security Cards
- Student ID Cards
- Work Permits and Residence Permits


Learn more about the API -> https://docs.aws.amazon.com/textract/latest/dg/analyzing-document-identity.html
Learn more about the response object -> https://docs.aws.amazon.com/textract/latest/dg/identitydocumentfields.html
"""

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.typing import LambdaContext

logger = Logger(service="analyze_id")


def lambda_handler(event: dict, context: LambdaContext) -> None:
    return True

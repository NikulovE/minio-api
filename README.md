Minio deployment manifest + rest api scripts
Here is a Dockerfile for building Minio based on Alpine Linux, a manifest for deploying a Minio server in Kubernetes with post-configuration. 
In the Job, the Minio server connects to Samba DC 4, assigns policies to a domain user and a domain group. 
In API Scripts, commands are collected for curl to create-delete-download operation files for Minio S3 buckets using REST API commands, without the complexities of AWS SDK, AWS4 Signature.

Minio deployment manifest + rest api scripts
����� ���� Dockefile �� ������ Minio �� ���� Alpine Linux, �������� �� �������������� ������� Minio � Kubernetes � ���� ����������.
� Job ������ Minio ������������ � Samba DC 4, ��������� �������� ��������� ������������ � �������� ������
� API Scripts ������� ������� ��� curl �� ��������-��������-�������� ������ �� ������� Minio S3 � ������� REST API ������, ��� ���������� � AWS SDK, AWS4 Signature
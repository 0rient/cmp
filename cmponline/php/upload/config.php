<?php
	
	//���ݿ���������======================================================================
	//���ݿ��û�
	define('EZSQL_DB_USER', "root");
	//���ݿ�����
	define('EZSQL_DB_PASSWORD', "copacast");
	//���ݿ���
	define('EZSQL_DB_NAME', "cmponline");
	//���ݿ������
	define('EZSQL_DB_HOST', "localhost");
	//====================================================================================

	//���ݱ�ǰ׺
	$table_prefix  = 'cmpo_';
	
	//Ĭ���ַ�����
	$charset = 'utf-8';
	
	//Ĭ��xml�����ļ�·��
	define('PATH_XML', "xml/");

	//��ʼ�����ݿ�����====================================================================
	include_once "libs/ez_sql_core.php";
	include_once "libs/ez_sql_mysql.php";
	//
	$db = new ezSQL_mysql(EZSQL_DB_USER, EZSQL_DB_PASSWORD, EZSQL_DB_NAME, EZSQL_DB_HOST);
	//====================================================================================
	
	//�������߿�
	include_once "libs/functions.php";
	
?>
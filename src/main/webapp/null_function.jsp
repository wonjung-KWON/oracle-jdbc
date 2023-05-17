<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
//오라클 DB 연결코드작성
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "gdj66";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl,dbuser,dbPw);
	System.out.println(conn + "<-- 디비 드라이브 연결확인");
	//결과셋에 사용할 변수 선언
	PreparedStatement nvlStmt = null;
	PreparedStatement nvl2Stmt = null;
	PreparedStatement nullifStmt = null;
	PreparedStatement coalesceStmt = null;
	ResultSet nvlRs = null;
	ResultSet nvl2Rs = null;
	ResultSet nullifRs = null;
	ResultSet coalesceRs = null;
	String nvlSql = null;
	String nvl2Sql = null;
	String nullifSql = null;
	String coalesceSql = null;
	/*
		nvi 함수를 쓰는 쿼리
		select 이름, nvl(일분기, 0) from 실적;
	*/
	nvlSql = "select 이름, nvl(일분기, 0) as 분기 from 실적";
	nvlStmt = conn.prepareStatement(nvlSql);
	nvlRs = nvlStmt.executeQuery();
	/*
		nvi2 함수를 쓰는 쿼리
		select 이름, nvl2(일분기, 'success', 'fail') from 실적;
	*/
	nvl2Sql = "select 이름, nvl2(일분기, 'success', 'fail')as 분기 from 실적";
	nvl2Stmt = conn.prepareStatement(nvl2Sql);
	nvl2Rs = nvl2Stmt.executeQuery();
	
	/*
		nullif 함수를 쓰는 쿼리
		select 이름, nullif(사분기, 100) from 실적;
	*/
	nullifSql = "select 이름, nullif(사분기, 100)as 분기 from 실적";
	nullifStmt = conn.prepareStatement(nullifSql);
	nullifRs = nullifStmt.executeQuery();
	
	/*
		coalesce 함수를 쓰는 쿼리
		select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) from 실적;
	*/
	coalesceSql = "select 이름, coalesce(일분기, 이분기, 삼분기, 사분기) as 분기 from 실적";
	coalesceStmt = conn.prepareStatement(coalesceSql);
	coalesceRs = coalesceStmt.executeQuery();

	// HashMap과 ArrayList를 사용하여 결과값 List에 저장
		//확장 함수를 쓰지 않는 결과셋
		ArrayList<HashMap<String, Object>> nvlList = new ArrayList<>();
		while(nvlRs.next()){
			HashMap<String, Object> n = new HashMap<String, Object>();
			n.put("이름", nvlRs.getString("이름"));
			n.put("분기", nvlRs.getInt("분기"));
			nvlList.add(n);
		}
		System.out.println(nvlList+"<-nvllist");
		ArrayList<HashMap<String, Object>> nvl2List = new ArrayList<>();
		while(nvl2Rs.next()){
			HashMap<String, Object> n2 = new HashMap<String, Object>();
			n2.put("이름", nvl2Rs.getString("이름"));
			n2.put("분기", nvl2Rs.getString("분기"));
			nvl2List.add(n2);
		}
		System.out.println(nvl2List);
		ArrayList<HashMap<String, Object>> nullifList = new ArrayList<>();
		while(nullifRs.next()){
			HashMap<String, Object> nif = new HashMap<String, Object>();
			nif.put("이름", nullifRs.getString("이름"));
			nif.put("분기", nullifRs.getInt("분기"));
			nullifList.add(nif);
		}
		System.out.println(nullifList);
		ArrayList<HashMap<String, Object>> cList = new ArrayList<>();
		while(coalesceRs.next()){
			HashMap<String, Object> c = new HashMap<String, Object>();
			c.put("이름", coalesceRs.getString("이름"));
			c.put("분기", coalesceRs.getInt("분기"));
			cList.add(c);
		}
		System.out.println(cList);
%>
<!DOCTYPE html>
<html>
<head>
	<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<h1>Null FUNCTION</h1>
	<div class="row">
		<div class="col-sm">
			<table class="table">
				<tr>
					<th>nvl</th>
				</tr>
				<%
					for(HashMap<String, Object> n : nvlList){
				%>
					<tr class="table-primary">
						<td><%=(String)(n.get("이름"))%></td>
						<td><%=(Integer)(n.get("분기"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
		</div>
		<div class="col-sm">
			<table class="table">
				<tr>
					<th>nvl2</th>
				</tr>
				<%
					for(HashMap<String, Object> n2 : nvl2List){
				%>
					<tr class="table-danger">
						<td><%=(String)(n2.get("이름"))%></td>
						<td><%=(String)(n2.get("분기"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
		</div>
		<div class="col-sm">
			<table class="table">
				<tr>
					<th>nullif</th>
				</tr>
				<%
					for(HashMap<String, Object> nif : nullifList){
				%>
					<tr class="table-info">
						<td><%=(String)(nif.get("이름"))%></td>
						<td><%=(Integer)(nif.get("분기"))%></td>
					</tr>
				<% 
					}
				%>
			</table >
		</div>
		<div class="col-sm">
			<table class="table">
				<tr>
					<th>coalesce</th>
				</tr>
				<%
					for(HashMap<String, Object> c : cList){
				%>
					<tr class="table-primary">
						<td><%=(String)(c.get("이름"))%></td>
						<td><%=(Integer)(c.get("분기"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
		</div>
	</div>
</body>
</html>
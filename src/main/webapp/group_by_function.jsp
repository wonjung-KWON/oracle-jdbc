<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
	//오라클 DB 연결코드작성
	String driver = "oracle.jdbc.driver.OracleDriver";
	String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
	String dbuser = "hr";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = null;
	conn = DriverManager.getConnection(dbUrl,dbuser,dbPw);
	System.out.println(conn + "<-- 디비 드라이브 연결확인");
	// 결과셋에 사용할 변수 들 선언
	PreparedStatement noStmt = null;
	PreparedStatement rollupStmt = null;
	PreparedStatement cubeStmt = null;
	ResultSet noRs = null;
	ResultSet rollupRs = null;
	ResultSet cubeRs = null;
	String noSql = null;
	String rollupSql = null;
	String cubeSql = null;
	/*
	확장 함수를 쓰지 않는 쿼리ㅏ
	select department_id, job_id, count(*) from employees group by department_id, job_id;
	*/
	noSql = "select department_id 부서ID, job_id 직무ID, count(*)부서인원 from employees group by department_id, job_id";
	noStmt = conn.prepareStatement(noSql);
	noRs = noStmt.executeQuery();
	/*
	확장 함수rollup을 사용한 쿼리
	select department_id, job_id, count(*) from employees
	group by rollup(department_id, job_id);
	*/
	rollupSql = "select department_id 부서ID, job_id 직무ID, count(*) 부서인원 from employees group by rollup(department_id, job_id)";
	rollupStmt = conn.prepareStatement(rollupSql);
	rollupRs = rollupStmt.executeQuery();
	
	/*
	확장함수 cube를 사용한 쿼리
	select department_id, job_id, count(*) from employees group by cube(department_id, job_id);
	*/
	cubeSql = "select department_id 부서ID, job_id 직무ID, count(*) 부서인원 from employees group by cube(department_id, job_id)";
	cubeStmt = conn.prepareStatement(cubeSql);
	cubeRs = cubeStmt.executeQuery();
	
	// HashMap과 ArrayList를 사용하여 결과값 List에 저장
	//확장 함수를 쓰지 않는 결과셋
	ArrayList<HashMap<String, Object>> noList = new ArrayList<>();
	while(noRs.next()){
		HashMap<String, Object> n = new HashMap<String, Object>();
		n.put("부서ID", noRs.getInt("부서ID"));
		n.put("직무ID", noRs.getString("직무ID"));
		n.put("부서인원", noRs.getInt("부서인원"));
		noList.add(n);
	}
	System.out.println(noList);
	//확장함수 rollup을 사용한 결과셋
	ArrayList<HashMap<String, Object>> rollupList = new ArrayList<>();
	while(rollupRs.next()){
		HashMap<String, Object> r = new HashMap<String, Object>();
		r.put("부서ID", rollupRs.getInt("부서ID"));
		r.put("직무ID", rollupRs.getString("직무ID"));
		r.put("부서인원", rollupRs.getInt("부서인원"));
		rollupList.add(r);
	}
	System.out.println(rollupList);
	//확장함수 cube를 사용한 결과셋
	ArrayList<HashMap<String, Object>> cubeList = new ArrayList<>();
	while(cubeRs.next()){
		HashMap<String, Object> c = new HashMap<String, Object>();
		c.put("부서ID", cubeRs.getInt("부서ID"));
		c.put("직무ID", cubeRs.getString("직무ID"));
		c.put("부서인원", cubeRs.getInt("부서인원"));
		cubeList.add(c);
	}
	System.out.println(cubeList);
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
	<h1>Employees table GROUP BY FUNCTION</h1>
	<div class="row">
		<div class="col-sm">
			<table class="table">
				<tr>
					<th>확장함수를 쓰는 않는 결과셋</th>
				</tr>
				<tr>
					<td>부서ID</td>
					<td>직무ID</td>
					<td>부서인원</td>
				</tr>
				<%
					for(HashMap<String, Object> n : noList){
				%>
					<tr class="table-primary">
						<td><%=(Integer)(n.get("부서ID"))%></td>
						<td><%=(String)(n.get("직무ID"))%></td>
						<td><%=(Integer)(n.get("부서인원"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
			</div>
			<div class="col-sm">
			<table class="table">
				<tr>
					<th>확장함수 rollup을 사용한 결과셋</th>
				</tr>
				<tr>
					<td>부서ID</td>
					<td>직무ID</td>
					<td>부서인원</td>
				</tr>
				<%
					for(HashMap<String, Object> r : rollupList){
				%>
					<tr class="table-danger">
						<td><%=(Integer)(r.get("부서ID"))%></td>
						<td><%=(String)(r.get("직무ID"))%></td>
						<td><%=(Integer)(r.get("부서인원"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
			</div>
			<div class="col-sm">
			<table class="table">
				<tr>
					<th>확장함수 cube을 사용한 결과셋</th>
				</tr>
				<tr>
					<td>부서ID</td>
					<td>직무ID</td>
					<td>부서인원</td>
				</tr>
				<%
					for(HashMap<String, Object> c : cubeList){
				%>
					<tr class="table-info">
						<td><%=(Integer)(c.get("부서ID"))%></td>
						<td><%=(String)(c.get("직무ID"))%></td>
						<td><%=(Integer)(c.get("부서인원"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
		</div>
	</div>
</body>
</html>
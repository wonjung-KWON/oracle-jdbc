<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
/*
select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도
from
(select rownum 번호, last_name 이름, substr(last_name, 1, 1)이름첫글자 ,  salary 연봉, round(salary/12,2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도 
from employees)
where 번호 between 1 and 10;
*/
	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int totalRow = 0;
	//오라클 DB 연결코드작성
		String driver = "oracle.jdbc.driver.OracleDriver";
		String dbUrl = "jdbc:oracle:thin:@localhost:1521:xe";
		String dbuser = "hr";
		String dbPw = "java1234";
		Class.forName(driver);
		Connection conn = null;
		conn = DriverManager.getConnection(dbUrl,dbuser,dbPw);
		System.out.println(conn + "<-- 디비 드라이브 연결확인");
		// totalRow 구하기 위해 쿼리 count(*) 를 활용하여 가져오기
		String totalRowSql = "select count(*) from employees";
		PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
		ResultSet totalRowRs = totalRowStmt.executeQuery();
		if(totalRowRs.next()){
			// 가져온 count(*) 값을 totalRow 변수에 저장
			totalRow =  totalRowRs.getInt("count(*)");
		}
		
		
	int rowPerPage = 10; // 현재페이지
	int beginRow = (currentPage -1) * rowPerPage +1 ; //시작하는행 변수에저장
	int endRow = beginRow + (rowPerPage - 1);//마지막 행 변수에 저장
	if(endRow > totalRow){ // 만약 마지막행이 총행보다 크다면 마지막행 변수에 총행을 저장
		endRow = totalRow;
	}
	//테이블값쿼리 작성
	String sql = "select 번호, 이름, 이름첫글자, 연봉, 급여, 입사날짜, 입사년도 from (select rownum 번호, last_name 이름, substr(last_name, 1, 1)이름첫글자 ,  salary 연봉, round(salary/12,2) 급여, hire_date 입사날짜, extract(year from hire_date) 입사년도  from employees) where 번호 between ? and ?";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow); // 시작하는 행
	stmt.setInt(2, endRow); // 끝나는 행
	ResultSet rs = stmt.executeQuery();
	// HashMap과 ArrayList를 사용하여 결과값 List에 저장
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	System.out.println(list.size()+"<-- list.size");
	while(rs.next()){
		HashMap<String, Object> h = new HashMap<String, Object>();
		h.put("번호", rs.getInt("번호"));
		h.put("이름", rs.getString("이름"));
		h.put("이름첫글자", rs.getString("이름첫글자"));
		h.put("연봉", rs.getInt("연봉"));
		h.put("급여", rs.getDouble("급여"));
		h.put("입사날짜", rs.getString("입사날짜"));
		h.put("입사년도", rs.getInt("입사년도"));
		list.add(h);
	}
	System.out.println(list.size()+"<-- list.size");
	
	// 페이지 네비게이션 페이징
	/*	cp	minPage ~ maxPage
		 1 	  1		~	10
		 2 	  1		~	10
		 
		 11   11	~	20
		 12   11	~	20
		 
		 21   21	~	30
		(cp-1) / pagePerPage * pagePerPage + 1 --> minPage // 실수연산 계산되지 않는다.
		minPage + (pagePerPage - 1 )--> maxPage
		maxPage > lastPage --> maxPage = lastPage
	*/
	int lastPage = totalRow / rowPerPage;
	if(totalRow % rowPerPage != 0){
		lastPage = lastPage + 1;
	}
	int pagePerPage = 10;// 페이지 숫자를 몇개를 보여줄지
	
	int minPage = ((currentPage - 1) / pagePerPage) * pagePerPage + 1;
	int maxPage = minPage + (pagePerPage -1);
	if(maxPage > lastPage){
		maxPage =lastPage;
	}
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
    <style type="text/css">
		.glanlink {color: #000000;}
	</style>
</head>
<body>
	<table class="table">
		<tr class="table-danger">
			<td>번호</td>
			<td>이름</td>
			<td>이름첫글자</td>
			<td>연봉</td>
			<td>급여</td>
			<td>입사날짜</td>
			<td>입사년도</td>
		</tr>
		<%
			for(HashMap<String, Object> h : list){
		%>	
			<tr class="table-primary">
				<td><%=(Integer)h.get("번호")%></td>
				<td><%=(String)h.get("이름")%></td>
				<td><%=(String)h.get("이름첫글자")%></td>
				<td><%=(Integer)h.get("연봉")%></td>
				<td><%=(Double)h.get("급여")%></td>
				<td><%=(String)h.get("입사날짜")%></td>
				<td><%=(Integer)h.get("입사년도")%></td>
			</tr>	
		<% 		
			}
		%>
	</table>
	<%
	if(minPage > 1){
	%>
		<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	
	<%
	}
		for(int i = minPage; i <= maxPage; i++){
			if(i == currentPage){
	%>
		<span class="glanlink"><%=i%></span>&nbsp;
	<% 	
			}else{
	%>
		<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
	<% 
			}
		}
	%>
	<%
		if(maxPage != lastPage){
	%>
	<a href="<%=request.getContextPath()%>/functionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}
	%>
</body>
</html>
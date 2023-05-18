<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%
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
			
	int rowPerPage = 10; // 페이지당 출력될 행
	int beginRow = (currentPage - 1) * rowPerPage + 1 ;
	int endRow = beginRow+(rowPerPage-1);
	// totalRow 구하기 위해 쿼리 count(*) 를 활용하여 가져오기
			String totalRowSql = "select count(*) from employees";
			PreparedStatement totalRowStmt = conn.prepareStatement(totalRowSql);
			ResultSet totalRowRs = totalRowStmt.executeQuery();
			if(totalRowRs.next()){
				// 가져온 count(*) 값을 totalRow 변수에 저장
				totalRow =  totalRowRs.getInt("count(*)");
			}
	//테이블 쿼리 작성
	/*
	select 번호, 사원ID, 마지막이름, 급여, 전체급여평균, 전체급여합계, 전체사원수 from(select rownum 번호, employee_id 사원ID, last_name 마지막이름, salary 급여, round(avg(salary) over(), 0) 전체급여평균, sum(salary) over() 전체급여합계, count(*) over() 전체사원수 from employees) where 번호 between ? and ? 
	*/
	String sql = "select 번호, 사원ID, 마지막이름, 급여, 전체급여평균, 전체급여합계, 전체사원수 from(select rownum 번호, employee_id 사원ID, last_name 마지막이름, salary 급여, round(avg(salary) over(), 0) 전체급여평균, sum(salary) over() 전체급여합계, count(*) over() 전체사원수 from employees) where 번호 between ? and ? ";
	PreparedStatement stmt = conn.prepareStatement(sql);
	stmt.setInt(1, beginRow);//시작하는 행
	stmt.setInt(2, endRow);// 끝나느행
	ResultSet rs = stmt.executeQuery();
	// HashMap과 ArrayList를 사용하여 결과값 List에 저장
	ArrayList<HashMap<String, Object>> list = new ArrayList<>();
	while(rs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("사원ID", rs.getInt("사원ID"));
		m.put("마지막이름", rs.getString("마지막이름"));
		m.put("급여", rs.getInt("급여"));
		m.put("전체급여평균", rs.getInt("전체급여평균"));
		m.put("전체급여합계", rs.getInt("전체급여합계"));
		m.put("전체사원수", rs.getInt("전체사원수"));
		list.add(m);
	}
	System.out.println(list.size()+"<-- list.size");
	//
	int lastPage = totalRow / rowPerPage;
	if(totalRow % lastPage != 0){
		lastPage = lastPage + 1;
	}
	int pagePerPage = 10; // 페이지 숫자를 몇개를 할지
	
	int minPage = ((currentPage -1) / pagePerPage) *pagePerPage + 1;// 1~10 을 1로  11 ~20을 2로 고정할 수 있는 알고리즘사용
	int maxPage = minPage + (pagePerPage - 1);// minPage에 맞게 하기위해 고정값설정
	if(maxPage > lastPage){// lastPage보다 크면안되기 때문에 if문 사용하여 크다면 lastpage를 대입
		maxPage = lastPage;
	}
%>
<!DOCTYPE html>
<html>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<style type="text/css">
		.glanlink {color: #000000;}
</style>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<table class="table">
		<tr>
			<td>사원ID</td>
			<td>마지막이름</td>
			<td>급여</td>
			<td>전체급여평균</td>
			<td>전체급여합계</td>
			<td>전체사원수</td>
		</tr>
		
		<%
			for(HashMap<String, Object> m : list){
		%>
		<tr class="table-primary">
			<td><%=(Integer)m.get("사원ID")%></td>
			<td><%=(String)m.get("마지막이름")%></td>
			<td><%=(Integer)m.get("급여")%></td>
			<td><%=(Integer)m.get("전체급여평균")%></td>
			<td><%=(Integer)m.get("전체급여합계")%></td>
			<td><%=(Integer)m.get("전체사원수")%></td>
		</tr>
		<%
			}
		%>
	</table>
	<%
	if(minPage > 1){
	%>
		<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	
	<%
	}
		for(int i = minPage; i <= maxPage; i++){
			if(i == currentPage){
	%>
		<span class="glanlink"><%=i%></span>&nbsp;
	<% 	
			}else{
	%>
		<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
	<% 
			}
		}
	%>
	<%
		if(maxPage != lastPage){
	%>
	<a href="<%=request.getContextPath()%>/windowsFunctionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}
	%>
</body>
</html>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.util.*" %>
<%

	int currentPage = 1;
	if(request.getParameter("currentPage") != null){
		currentPage = Integer.parseInt(request.getParameter("currentPage"));
	}
	int totalRow = 0;	
	
	String rankpage = null;
	if(request.getParameter("rankpage") != null){
		rankpage = request.getParameter("rankpage");
	}
	String denseRankpage = null;
	if(request.getParameter("denseRankpage") != null){
		denseRankpage = request.getParameter("denseRankpage");
	}
	String ntilepage = null;
	if(request.getParameter("ntilepage") != null){
		ntilepage = request.getParameter("ntilepage");
	}
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
	ArrayList<HashMap<String, Object>> rankList = null;
	ArrayList<HashMap<String, Object>> denseRankList = null;
	ArrayList<HashMap<String, Object>> ntileList = null;
			
			
	if(rankpage.equals("go")){		
	// rank 쿼리작성	
	String rankSql = "select 번호, 순위, 이름, 급여 from(select rownum 번호, 순위, 이름, 급여 from (select first_name 이름, salary 급여, rank() over(order by salary desc) 순위 from employees)) where 번호 between ?  and ?";
	PreparedStatement rankStmt = conn.prepareStatement(rankSql);
	rankStmt.setInt(1, beginRow);//시작하는 행
	rankStmt.setInt(2, endRow);// 끝나는행
	ResultSet rankRs = rankStmt.executeQuery();
	System.out.println(rankStmt +"<-- rankStmt");
	// HashMap과 ArrayList를 사용하여 결과값 List에 저장
	rankList = new ArrayList<>();
	while(rankRs.next()){
		HashMap<String, Object> m = new HashMap<String, Object>();
		m.put("순위", rankRs.getInt("순위"));
		m.put("이름", rankRs.getString("이름"));
		m.put("급여", rankRs.getInt("급여"));
		rankList.add(m);
	}

	System.out.println(rankList.size()+"<-- rankList.size");
	System.out.println(rankList +"<-- rankList");
	}else if(denseRankpage.equals("go")){
	//dense_rank 쿼리작성
	String denseRankSql = "select 번호, 순위, 이름, 급여 from(select rownum 번호, 순위, 이름, 급여 from (select first_name 이름, salary 급여, dense_rank() over(order by salary desc) 순위 from employees)) where 번호 between ?  and ?";
	PreparedStatement denseRankStmt = conn.prepareStatement(denseRankSql);
	denseRankStmt.setInt(1, beginRow);//시작하는 행
	denseRankStmt.setInt(2, endRow);// 끝나는행
	ResultSet denseRankRs = denseRankStmt.executeQuery();
	System.out.println(denseRankStmt +"<-- denseRankStmt");
	// HashMap과 ArrayList를 사용하여 결과값 List에 저장
	 denseRankList = new ArrayList<>();
	while(denseRankRs.next()){
		HashMap<String, Object> dm = new HashMap<String, Object>();
		dm.put("순위", denseRankRs.getInt("순위"));
		dm.put("이름", denseRankRs.getString("이름"));
		dm.put("급여", denseRankRs.getInt("급여"));
		denseRankList.add(dm);
	}

	System.out.println(denseRankList.size()+"<-- denseRankList.size");
	System.out.println(denseRankList +"<-- denseRankList");
	}else if(ntilepage.equals("go")){
	
	// ntile 쿼리작성
	String ntileSql = "select 번호, 그룹, 이름, 급여 from(select rownum 번호, 그룹, 이름, 급여 from (select first_name 이름, salary 급여, ntile(10) over(order by salary desc) 그룹 from employees)) where 번호 between ?  and ?";
	PreparedStatement ntileStmt = conn.prepareStatement(ntileSql);
	ntileStmt.setInt(1, beginRow);//시작하는 행
	ntileStmt.setInt(2, endRow);// 끝나는행
	ResultSet ntileRs = ntileStmt.executeQuery();
	System.out.println(ntileStmt +"<-- ntileStmt");
	// HashMap과 ArrayList를 사용하여 결과값 List에 저장
	ntileList = new ArrayList<>();
	while(ntileRs.next()){
		HashMap<String, Object> nm = new HashMap<String, Object>();
		nm.put("그룹", ntileRs.getInt("그룹"));
		nm.put("이름", ntileRs.getString("이름"));
		nm.put("급여", ntileRs.getInt("급여"));
		ntileList.add(nm);
	}

	System.out.println(ntileList.size()+"<-- ntileList.size");
	System.out.println(ntileList +"<-- ntileList");
	}
	
	//
	int lastPage = totalRow / rowPerPage;
	if(totalRow % lastPage != 0){
		lastPage = lastPage + 1;
	}
	int pagePerPage = 10; // 페이지 숫자를 몇개를 할지
	
	int minPage = ((currentPage -1) / pagePerPage) *pagePerPage + 1; // 1~10 을 1로  11 ~20을 2로 고정할 수 있는 알고리즘사용
	int maxPage = minPage + (pagePerPage - 1); // minPage에 맞게 하기위해 고정값설정
	if(maxPage > lastPage){ // lastPage보다 크면안되기 때문에 if문 사용하여 크다면 lastpage를 대입
		maxPage = lastPage;
	}
%>
<!DOCTYPE html>
<html>
<head>
<!-- Latest compiled and minified CSS -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Latest compiled JavaScript -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.2.3/dist/js/bootstrap.bundle.min.js"></script>
<style type="text/css">
		.glanlink {color: #000000;}
</style>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>rank_ntile_list</h1>
	<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?rankpage=go">rankList</a>
	<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?denseRankPage=go">dense rank List</a>
	<a href="<%=request.getContextPath()%>/rank_ntile_list.jsp?ntilepage=go">ntile List</a>
	<div class="row">
	<%
		if(rankpage != null){
	%>
		<div class="col-sm">
			<table class="table">
				<tr class="table-primary">
					<th>rank 함수 결과셋</th>
				</tr>
				<%
					for(HashMap<String, Object> m : rankList){
				%>
					<tr>
						<td><%=(Integer)(m.get("순위"))%></td>
						<td><%=(String)(m.get("이름"))%></td>
						<td><%=(Integer)(m.get("급여"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
		</div>
	<%
		}
	%>
	<%
		if(denseRankpage != null){
	%>
		<div>
			<table class="table">
				<tr class="table-danger">
					dense_rank 함수 결과
				</tr>
				<%
					for(HashMap<String, Object> dm : denseRankList){
				%>
					<tr>
						<td><%=(Integer)(dm.get("순위"))%></td>
						<td><%=(String)(dm.get("이름"))%></td>
						<td><%=(Integer)(dm.get("급여"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
		</div>
	<%
		}
	%>
	<%
		if(ntilepage != null){
	%>
		<div>
			<table class="table">
				<tr class="table-info">
				ntile 함수 결과셋
				</tr>
				<%
					for(HashMap<String, Object> nm : ntileList){
				%>
					<tr>
						<td><%=(Integer)(nm.get("그룹"))%></td>
						<td><%=(String)(nm.get("이름"))%></td>
						<td><%=(Integer)(nm.get("급여"))%></td>
					</tr>
				<% 
					}
				%>
			</table>
		</div>
		
	<%
		}
	%>
	</div>
	<%
	if(minPage > 1){
	%>
		<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=minPage-pagePerPage%>">이전</a>
	
	<%
	}
		for(int i = minPage; i <= maxPage; i++){
			if(i == currentPage){
	%>
		<span class="glanlink"><%=i%></span>&nbsp;
	<% 	
			}else{
	%>
		<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=i%>"><%=i%></a>&nbsp;
	<% 
			}
		}
	%>
	<%
		if(maxPage != lastPage){
	%>
	<a href="<%=request.getContextPath()%>/rankFunctionEmpList.jsp?currentPage=<%=minPage+pagePerPage%>">다음</a>
	<%
		}
	%>
</body>
</html>
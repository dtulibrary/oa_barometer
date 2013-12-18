<xsl:stylesheet version="1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:zs="http://www.loc.gov/zing/srw/"
	xmlns:mxd="http://mx.forskningsdatabasen.dk/ns/documents/1.3"
	exclude-result-prefixes="">
	
  	<xsl:output method="text" version="1.0" encoding="utf-8"/>
  	
  	<xsl:param name="includeHeader" select="'yes'" />
  	
  	<xsl:param name="delim" select="'||'" />
  	<xsl:param name="quote" select="'&quot;'" />
  	<xsl:param name="break" select="'&#xA;'" /><!-- &#10;   -->
  	
  	<xsl:strip-space elements="*" />

	<!-- match root -->
	<xsl:template match="/">
		<xsl:if test="$includeHeader = 'yes'">
			<!-- number of records -->
			<xsl:value-of select="zs:searchRetrieveResponse/zs:numberOfRecords" />
			<xsl:value-of select="$break" />
			
			<!-- header-->
			<xsl:text>rec_id</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>rec_source</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>title</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>sub_title</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>full_title</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>doc_type</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>doc_review</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>doc_year</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>publication_year</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>issn</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>vol</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>issue</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>isbn</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>open_access</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>full_text_type</xsl:text><xsl:value-of select="$delim" />
			<xsl:text>full_text_uri</xsl:text>
			<xsl:value-of select="$break" />
		</xsl:if>
		<!-- record data -->
		<xsl:for-each select="zs:searchRetrieveResponse/zs:records/zs:record/zs:recordData/mxd:ddf_doc"> <!-- ./zs:searchRetrieveResponse/zs:records/zs:record/zs:recordData/ -->
			<xsl:value-of select="./@rec_id"/><xsl:value-of select="$delim" />
			<xsl:value-of select="./@rec_source"/><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:title/mxd:original/mxd:main/text()"/><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:title/mxd:original/mxd:sub/text()"/><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:title/mxd:original/mxd:main/text()"/><xsl:if test="string-length(./mxd:title/mxd:original/mxd:sub/text()) &gt; 0"><xsl:text>: </xsl:text><xsl:value-of select="./mxd:title/mxd:original/mxd:sub/text()"/></xsl:if><xsl:value-of select="$delim" />
			<xsl:value-of select="./@doc_type"/><xsl:value-of select="$delim" />
			<xsl:value-of select="./@doc_review"/><xsl:value-of select="$delim" />
			<xsl:value-of select="./@doc_year" /><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:publication/*/mxd:year/text()" /><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:publication/*/mxd:issn/text()" /><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:publication/*/mxd:vol/text()" /><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:publication/*/mxd:issue/text()" /><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:publication/*/mxd:isbn[@type='pri']/text()" /><xsl:value-of select="$delim" />
			<xsl:choose>
				<xsl:when test="./mxd:publication/mxd:digital_object[@access='oa']">yes</xsl:when>
				<xsl:otherwise>no</xsl:otherwise>
			</xsl:choose>
			<xsl:value-of select="$delim" />			
			<xsl:value-of select="./mxd:publication/mxd:digital_object[@access='oa']/@role" /><xsl:value-of select="$delim" />
			<xsl:value-of select="./mxd:publication/mxd:digital_object[@access='oa']/mxd:uri/text()" />
			
			<xsl:value-of select="$break" />
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>

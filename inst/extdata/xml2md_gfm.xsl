<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:md="http://commonmark.org/xml/1.0">


    <!-- Import commonmark XSL -->

    <xsl:import href="xml2md.xsl"/>
    <xsl:template match="/">
        <xsl:apply-imports/>
    </xsl:template>

    <!-- params -->

    <xsl:output method="text" encoding="utf-8"/>

      <!-- Text that needs to be preserved (e.g. math/checkboxes) -->

    <xsl:template match="md:emph[@asis='true']">
      <!-- 
        Multiple subscripts in a LaTeX equation will result in emph tags.
        our stylesheet enforces "*" for emph, we are using this workaround
        for aiss emph.
      -->
      <xsl:text>_</xsl:text>
      <xsl:apply-templates select="md:text[@asis='true']"/>
      <xsl:text>_</xsl:text>
    </xsl:template>

    <xsl:template match="md:text[@asis='true']">
      <xsl:value-of select='string(.)'/>
    </xsl:template>

    <xsl:template match="md:link[@rel] | md:image[@rel]">
      <xsl:if test="self::md:image">!</xsl:if>
      <xsl:text>[</xsl:text>
      <xsl:apply-templates select="md:*"/>
      <xsl:text>][</xsl:text>
      <xsl:value-of select='string(@rel)'/>
      <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="md:link[@anchor]">
    <xsl:if test="self::md:image">!</xsl:if>
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="md:*"/>
    <xsl:text>]: </xsl:text>
    <xsl:call-template name="escape-text">
        <xsl:with-param name="text" select="string(@destination)"/>
        <xsl:with-param name="escape" select="'()'"/>
    </xsl:call-template>
    <xsl:if test="string(@title)">
        <xsl:text> "</xsl:text>
        <xsl:call-template name="escape-text">
            <xsl:with-param name="text" select="string(@title)"/>
            <xsl:with-param name="escape" select="'&quot;'"/>
        </xsl:call-template>
        <xsl:text>"</xsl:text>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    </xsl:template>



    <!-- Table -->

    <xsl:template match="md:table">
        <xsl:apply-templates select="." mode="indent-block"/>
        <xsl:apply-templates select="md:*"/>
    </xsl:template>

    <xsl:variable name="minLength">3</xsl:variable>

    <xsl:variable name="maxLength">
        <xsl:for-each select="//md:table_header/md:table_cell">
            <xsl:variable name="pos" select="position()"/>
            <!-- EXslt or XSLT 1.1 would be needed to lookup node-sets;
                thus generating a string (something like CELL1:7|CELL2:5|CELL3:9|CELL4:8|) -->
            <xsl:text>CELL</xsl:text>
            <xsl:value-of select="$pos"/>
            <xsl:text>:</xsl:text>
            <xsl:for-each select="//md:table_cell[position()=$pos]/md:text">
                <xsl:sort data-type="number" select="string-length()" order="descending"/>
                <xsl:if test="position()=1">
                    <xsl:value-of select="string-length()"/>
                    <xsl:value-of select="'|'"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:variable>

    <!-- recursive template to print n dashes/characters -->
    <xsl:template name="n-times">
        <xsl:param name="n"/>
        <xsl:param name="char"/>
        <xsl:if test="$n > 0">
            <xsl:call-template name="n-times">
                <xsl:with-param name="n" select="$n - 1"/>
                <xsl:with-param name="char" select="$char"/>
            </xsl:call-template>
            <xsl:value-of select="$char"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="md:table_header">
        <xsl:text>| </xsl:text>
        <xsl:apply-templates select="md:*"/>
        <xsl:text>&#xa;| </xsl:text>
        <xsl:for-each select="md:table_cell">
            <!-- helper variable for the lookup -->
            <xsl:variable name="cell" select="concat('CELL',position())"/>
            <!-- length of longest value in col -->
            <xsl:variable name="maxFill" select="number(substring-before(substring-after($maxLength,concat($cell,':')),'|'))"/>
            <xsl:variable name="fill">
                <xsl:choose>
                    <xsl:when test="$maxFill &lt; $minLength">
                        <xsl:value-of select="$minLength"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$maxFill"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="position() != 1">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="@align = 'right'">
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill -1"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text>: |</xsl:text>
                </xsl:when>
                <xsl:when test="@align = 'left'">
                    <xsl:text>:</xsl:text>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill -1"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text> |</xsl:text>
                </xsl:when>
                <xsl:when test="@align = 'center'">
                    <xsl:text>:</xsl:text>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill -2"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text>: |</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="n-times">
                        <xsl:with-param name="n" select="$fill"/>
                        <xsl:with-param name="char" select="'-'"/>
                    </xsl:call-template>
                    <xsl:text> |</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="md:table_cell">
        <xsl:variable name="cell" select="concat('CELL',position())"/>
        <!-- length of longest value in col -->
        <xsl:variable name="maxFill" select="number(substring-before(substring-after($maxLength,concat($cell,':')),'|'))"/>
        <xsl:variable name="fill">
            <xsl:choose>
                <xsl:when test="$maxFill &lt; $minLength">
                    <xsl:value-of select="$minLength - string-length(md:text)"/>
                </xsl:when>
                <xsl:when test="string-length(md:text)=$maxFill">0</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$maxFill - string-length(md:text)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:apply-templates select="md:*"/>
        <xsl:call-template name="n-times">
            <xsl:with-param name="n" select="$fill"/>
            <xsl:with-param name="char" select="' '"/>
        </xsl:call-template>
        <xsl:text> | </xsl:text>
    </xsl:template>

    <xsl:template match="md:table_row">
        <xsl:text>| </xsl:text>
        <xsl:apply-templates select="md:*"/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <xsl:template match="md:table_row">
    <xsl:text>| </xsl:text>
    <xsl:apply-templates select="md:*"/>
    <xsl:text>&#xa;</xsl:text>
</xsl:template>


    <!-- Striked-through -->

    <xsl:template match="md:strikethrough">
        <xsl:text>~~</xsl:text>
        <xsl:apply-templates select="md:*"/>
        <xsl:text>~~</xsl:text>
    </xsl:template>

</xsl:stylesheet>

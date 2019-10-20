<%@ page info="index" contentType="text/html; charset=utf-8" pageEncoding="utf-8" session="false" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<c:set var="cfg" value="${applicationScope['cfg']}" />
<c:set var="contextroot" value="${pageContext.request.contextPath}" />
<c:if test="${(pageContext.request.scheme == 'http' && pageContext.request.serverPort != 80) ||
        (pageContext.request.scheme == 'https' && pageContext.request.serverPort != 443) }">
    <c:set var="port" value=":${pageContext.request.serverPort}" />
</c:if>
<c:set var="scheme" value="${(not empty header['x-forwarded-proto']) ? header['x-forwarded-proto'] : pageContext.request.scheme}" />
<c:set var="hostpath" value="${scheme}://${pageContext.request.serverName}${port}${contextroot}" />
<c:if test="${!empty encoded}">
    <c:set var="imgurl" value="${hostpath}/png/${encoded}" />
    <c:set var="svgurl" value="${hostpath}/svg/${encoded}" />
    <c:set var="txturl" value="${hostpath}/txt/${encoded}" />
    <c:if test="${!empty mapneeded}">
        <c:set var="mapurl" value="${hostpath}/map/${encoded}" />
    </c:if>
</c:if>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta http-equiv="expires" content="0" />
    <meta http-equiv="pragma" content="no-cache" />
    <meta http-equiv="cache-control" content="no-cache, must-revalidate" />
    <link rel="icon" href="${contextroot}/favicon.ico" type="image/x-icon"/> 
    <link rel="shortcut icon" href="${contextroot}/favicon.ico" type="image/x-icon"/>
    <link rel="stylesheet" href="${contextroot}/plantuml.css" />
    <link rel="stylesheet" href="${contextroot}/goldenlayout-base.css" />
    <link rel="stylesheet" href="${contextroot}/goldenlayout-light-theme.css" />
    <script type="text/javascript" src="${contextroot}/jquery.min.js"></script>
    <script type="text/javascript" src="${contextroot}/goldenlayout.min.js"></script>
    <title>PlantUMLServer</title>
</head>
<body>
<div>
    <button>
        <img src="${contextroot}/horizontal-split.svg" />
    </button>
    <img src="${contextroot}/link.svg" alt="Link image" />
    <form method="post" action="${contextroot}/form">
        <input name="url" type="text" value="${imgurl}" />
        <button type="submit">
            <img src="${contextroot}/done.svg" alt="Link image" />
        </button>
    </form>
    <br />
</div>
<script type="text/javascript">
    var config = {
    settings:{
        hasHeaders: true,
        constrainDragToContainer: true,
        reorderEnabled: true,
        selectionEnabled: false,
        popoutWholeStack: false,
        blockedPopoutsThrowError: true,
        closePopoutsOnUnload: true,
        showPopoutIcon: false,
        showMaximiseIcon: true,
        showCloseIcon: false
    },
    content: [{
        type: 'row',
        content: [
            {
            type:'component',
            componentName: 'Editor',
            componentState: { text: 'Editor' }
            },
            {
            type:'component',
            componentName: 'Diagram',
            componentState: { text: 'Diagram' }
            }
        ]
    }]
    };

    var myLayout = new GoldenLayout(config); 

    var toggleRowColumn = function() {
        var oldElement = myLayout.root.contentItems[ 0 ],
            newElement = myLayout.createContentItem({ 
                type: oldElement.isRow ? 'column' : 'row',
                content: [] 
            }),
            i;

        //Prevent it from re-initialising any child items
        newElement.isInitialised = true;

        for( i = 0; i < oldElement.contentItems.length; i++ ) {
            newElement.addChild( oldElement.contentItems[ i ] );
        }

        myLayout.root.replaceChild( oldElement, newElement );
    };

    myLayout.registerComponent( 'Editor', function( container, state ){
        var html =`
        <form method="post" accept-charset="UTF-8"  action="${contextroot}/form">
        <p>
        <textarea id="text" name="text" cols="120" rows="10"><c:out value="${decoded}"/></textarea>
        <input type="submit" />
        </p>
        </form>
        `;
        container.getElement().html(html);
    });

    myLayout.registerComponent( 'Diagram', function( container, state ){
        var html = `
            <c:if test="${!empty(imgurl)}">
                <hr/>
                <a href="${svgurl}">View as SVG</a>&nbsp;
                <a href="${txturl}">View as ASCII Art</a>&nbsp;
                <c:if test="${!empty(mapurl)}">
                    <a href="${mapurl}">View Map Data</a>
                </c:if>
                <c:if test="${cfg['SHOW_SOCIAL_BUTTONS'] == 'on' }">
                    <%@ include file="resource/socialbuttons2.jspf" %>
                </c:if>
                <p id="diagram">
                    <c:choose>
                    <c:when test="${!empty(mapurl)}">
                        <img src="${imgurl}" alt="PlantUML diagram" />
                    </c:when>
                    <c:otherwise>
                        <img src="${imgurl}" alt="PlantUML diagram" />
                    </c:otherwise>
                    </c:choose>
                </p>
            </c:if>
        `;

        container.getElement().html(html);
    });

    myLayout.init();
</script>
</body>
</html>

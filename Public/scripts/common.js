function responseSuccess(data) {
    if (data.code >= 200 && data.code < 300) {
        return true;
    } else {
        return false;
    }

}

function loadMoreArticles() {
    // This is a placeholder function.
    // In a real application, you would make an AJAX request here
    // to fetch more articles and append them to the list.
    console.log("Load more articles button clicked!");
    alert("加载更多文章功能待实现！");
}

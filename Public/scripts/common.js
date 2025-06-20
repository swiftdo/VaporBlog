function responseSuccess(data) {
    if (data.code >= 200 && data.code < 300) {
        return true;
    } else {
        return false;
    }

}
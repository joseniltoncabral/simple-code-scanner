$(function () {
    createAccordion();
    loadData();
});

function createAccordion() {
    $("#container").accordion({ collapsible: true, active: false });
}

function loadData() {
    for (var i = 0; i < checkedElements.length; i++) {
        document.getElementById(checkedElements[i]).checked = true;
    }
}

function save() {
    var checkedElements = [];

    $("input:checkbox:checked").each(function (index, value) {
        checkedElements.push(value.id);
    });

    if (checkedElements.length > 0) {
        var a = document.createElement('a');
        a.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent('checkedElements=' + JSON.stringify(checkedElements)));
        a.setAttribute('download', "data.js");
        a.click();
    }
}
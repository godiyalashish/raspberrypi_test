function togglePasswordVisibility() {
    var passwordInput = document.getElementById("password");
    var icon = document.querySelector('.toggle-password img');
    if (passwordInput.type === "password") {
        passwordInput.type = "text";
        icon.src = "https://img.icons8.com/material-outlined/24/000000/visible--v1.png";
    } else {
        passwordInput.type = "password";
        
        icon.src = "https://img.icons8.com/material-outlined/24/000000/invisible.png";
    }
}

function submitDetails(e){
    e.preventDefault();
    var form = e.target;
    var formData = new FormData(form);
    var formValues = {};
    for (var [key, value] of formData.entries()) {
        formValues[key] = value;
    }
    console.log(formValues);
}
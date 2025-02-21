window.addEventListener('message', (event) => {
    const e = event.data;

    switch (e.action) {
        case 'show':
            $('.container').fadeIn(400)
            $('#motivo').html(`Reason: <span>${e.motivo}</span>`)
            $('#admin').html(`Admin: <span>${e.admin}</span>`)
            $('#restantes').html(`Remaining: <span>${e.restantes}</span>`)
            $('#total').html(`Total: <span>${e.total}</span>`)
        break;
        case 'update':
            $('#restantes').html(`Remaining: <span>${e.restantes}</span>`)
        break;
        case 'hide':
            $('.container').fadeOut(400)
        break;
    }
});
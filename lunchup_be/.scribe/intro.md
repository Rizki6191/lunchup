# Introduction



<aside>
    <strong>Base URL</strong>: <code>http://localhost:8000</code>
</aside>

    This documentation aims to provide all the information you need to work with our API.

    <aside>As you scroll, you'll see code examples for working with the API in different programming languages in the dark area to the right (or as part of the content on mobile).
    You can switch the language used with the tabs at the top right (or from the nav menu at the top left on mobile).</aside>

    ## Authentication
    This API uses Bearer Token authentication.
    To authenticate, you need to add the `Authorization` header to your requests:
    `Authorization: Bearer {your-token}`

    You can get a token by logging in via `POST /api/auth/login`.
    Once you have the token, you can paste it in the **"Try It Out"** section (click the button next to an endpoint) to make authenticated requests directly from this documentation.


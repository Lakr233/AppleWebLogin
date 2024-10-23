# AppleWebLogin

This package is able to fix:

- https://github.com/XcodesOrg/XcodesApp/issues/630#issuecomment-2430957975
- https://github.com/majd/ipatool/issues/301

The token returned by this package will get you directory service identifier, listed as `prsId` in response from Apple.

```
curl 'https://appstoreconnect.apple.com/olympus/v1/session' \
  -H 'Cookie: myacinfo=$TOKEN'

{
    "user" : {
        "fullName" : "砍砍",
        "firstName" : "砍",
        "lastName" : "砍",
        "emailAddress" : "砍砍@icloud.com",
        "prsId" : "1145141919810"
    },
    ...
}
```

You can then use it to download apps from App Store.

## License

[MIT License](./LICENSE)

---

Copyright © 2024 Lakr Aream. All Rights Reserved.

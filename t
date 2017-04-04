superuser and admin role in different context

https://github.com/buzzn/buzzn/issues/817 just brings me back to permissions and context.

we have places where we use different permissions then the 'standard' permissions:

https://github.com/buzzn/buzzn/blob/master/app/models/register/base.rb#L154-L161



and there are other places where we add more permission related anonymization to our retrieve queries:
https://github.com/buzzn/buzzn/blob/master/app/models/register/base.rb#L108-L118


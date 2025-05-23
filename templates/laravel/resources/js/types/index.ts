export type AuthenticatedUserProps = {
  id: number
  email: string
  name: string
  gravatar: string
  email_verified_at: string | null
}
export type FlashProps = {
  type: string
  message: string
}

export type PageProps = {
  auth: {
    user: AuthenticatedUserProps
  }
  ziggy: {
    location: string;
    query: [];
    route: {
      component: string
      id: string
    };
  },
  flash: FlashProps
}

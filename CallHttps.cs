var result = new HttpResponseMessage();

            string json = JsonConvert.SerializeObject(request);
            StringContent content = new StringContent(json, UnicodeEncoding.UTF8, "application/json");

            using (var clienHandler = new HttpClientHandler())
            {
                clienHandler.ServerCertificateCustomValidationCallback = (s, ce, ca, p) => true;

                using (var client = new HttpClient(clienHandler))
                {

                    result = client.PostAsync($"{FrejaAuthorizerAddress.BaseAddress}{FrejaEnpointsCatalog.GetTransactionByReferenceEndPoint}", content).Result;

                    if (result.IsSuccessStatusCode)
                    {
                        GetTransactionByReferenceResponse response = await result.Content.ReadAsAsync<GetTransactionByReferenceResponse>();

                        return new Tuple<bool, GetTransactionByReferenceResponse, ErrorFrejaResponse>(true, response, null);
                    }
                    else if (result.StatusCode == System.Net.HttpStatusCode.BadRequest)
                    {
                        ErrorFrejaResponse error = await result.Content.ReadAsAsync<ErrorFrejaResponse>();

                        return new Tuple<bool, GetTransactionByReferenceResponse, ErrorFrejaResponse>(false, null, error);
                    }
                    else
                    {
                        return null;
                    }

                }
            }
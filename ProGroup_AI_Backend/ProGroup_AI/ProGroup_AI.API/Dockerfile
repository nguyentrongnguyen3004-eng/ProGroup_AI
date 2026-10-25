FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["ProGroup_AI.API.csproj", "./"]
RUN dotnet restore "ProGroup_AI.API.csproj"
COPY . .
RUN dotnet publish "ProGroup_AI.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "ProGroup_AI.API.dll"]

import * as functions from "firebase-functions";
import { Client } from "@notionhq/client";

const notion = new Client({ auth: functions.config().notion.key });
const databaseId = functions.config().notion.database.id;

export const enviarEmailParaNotion = functions.auth.user().onCreate(
    async (user: { email: any; }) => {
        const userEmail: any = user.email;

        try {
            await notion.pages.create(<any>{
                parent: { database_id: databaseId },
                properties: {
                    Email: {
                        title: [{ type: "text", text: { content: userEmail } }],
                    },
                    Etapa: {
                        multi_select: [{ name: "Novo Cadastro" }]
                    },
                },
            });
            console.log('AUTH: Sincronização com Notion realizada com sucesso.');
        } catch (error) {
            console.log('AUTH: Erro na Sincronização com Notion.');
        }
        return true;
    }
);
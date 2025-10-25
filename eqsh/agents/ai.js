function callO(promptText, callback) {
  callback(true, {
    candidates: [
      {
        content: {
          parts: [
            { text: promptText }
          ]
        }
      }
    ]
  })
}

function call(promptText, apiKey, model, options = {}, callback) {
  const type = options.type || "google"; // "google" | "openai" | "other"

  let url, body, headers;

  if (type === "google") {
    let finalPrompt = `
      Chat History: ${options.previousMessages ? JSON.stringify(options.previousMessages) : "Empty"}
      Prompt: ${promptText}
    `
    url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`;
    body = {
      contents: [
        { parts: [ { text: finalPrompt } ] }
      ],
      systemInstruction: options.systemPrompt
      ? { role: "system", parts: [{ text: options.systemPrompt }] }
      : undefined,
    };
    headers = {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey
    };
  } else if (type === "openai") {
    url = "https://api.openai.com/v1/chat/completions";
    const messages = [];
    if (options.systemPrompt) {
      messages.push({ role: "system", content: options.systemPrompt });
    }
    if (options.previousMessages && Array.isArray(options.previousMessages)) {
      for (const m of options.previousMessages) {
        messages.push(m);
      }
    }
    messages.push({ role: "user", content: promptText });
    body = {
      model: model,
      messages: messages,
    };
    if (options.extraParams) {
      for (var key in options.extraParams) {
        body[key] = options.extraParams[key];
      }
    }

    headers = {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`
    };
  } else {
    console.error("Unsupported AI type");
    return;
  }

  var xhr = new XMLHttpRequest();
  xhr.open("POST", url);
  for (const key in headers) {
    xhr.setRequestHeader(key, headers[key]);
  }

  xhr.onreadystatechange = function() {
    if (xhr.readyState === XMLHttpRequest.DONE) {
      if (xhr.status === 200) {
        const response = JSON.parse(xhr.responseText);
        console.info("AI successfully generated");
        callback(true, response);
      } else {
        console.error("AI failed to generate:", xhr.responseText);
        callback(false, xhr.responseText);
      }
    }
  };

  xhr.send(JSON.stringify(body));
}